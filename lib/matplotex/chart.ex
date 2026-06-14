defmodule Matplotex.Chart do
  @moduledoc """
  Central chart struct and compile pipeline.

  ## Architecture

      spec (user builds) → compile/1 → frame (layout) → geometry (shapes) → SVG

  Dirty tracking ensures only changed layers recompute:

      :canvas  → :frame → :geometry
      :data    → :scales → :geometry
      :viewport →         :geometry

  ## Usage

      Chart.new(:line)
      |> Chart.put_dataset(dataset)
      |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Time"})
      |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Value"})
      |> Chart.set_title("My Chart")
      |> Chart.compile()
      |> Renderer.to_svg()
  """

  alias Matplotex.{Canvas, Viewport, Frame, Axis, Scale, Stat, Dataset}
  alias Matplotex.Chart.Behaviour

  @default_colors [
    "#4e79a7", "#f28e2b", "#e15759", "#76b7b2", "#59a14f",
    "#edc948", "#b07aa1", "#ff9da7", "#9c755f", "#bab0ac"
  ]

  @type t :: %__MODULE__{
          type: atom(),
          datasets: [Dataset.t()],
          axes: %{atom() => Axis.t()},
          title: String.t() | nil,
          canvas: Canvas.t(),
          viewport: Viewport.t(),
          frame: Frame.t() | nil,
          geometry: list(),
          dirty: MapSet.t()
        }

  defstruct type: :line,
            datasets: [],
            axes: %{},
            title: nil,
            canvas: %Canvas{},
            viewport: %Viewport{},
            frame: nil,
            geometry: [],
            dirty: MapSet.new([:frame, :scales, :geometry])

  # ── Builder API ───────────────────────────────────────────────────────────

  @doc "Creates a new chart of the given type."
  def new(type, opts \\ []) do
    canvas = Keyword.get(opts, :canvas, %Canvas{})
    %__MODULE__{type: type, canvas: canvas}
  end

  @doc "Adds or replaces a dataset. Multiple datasets = multiple series."
  def put_dataset(%__MODULE__{datasets: ds} = chart, %Dataset{} = dataset) do
    %{chart | datasets: ds ++ [dataset], dirty: mark(:data, chart.dirty)}
  end

  @doc "Shortcut: builds a Dataset from `{x, y}` pairs and appends it."
  def add_data(%__MODULE__{} = chart, pairs, opts \\ []) do
    put_dataset(chart, Dataset.from_pairs(pairs, opts))
  end

  @doc "Adds or replaces an axis by id."
  def put_axis(%__MODULE__{axes: axes} = chart, id, %Axis{} = axis) do
    %{chart | axes: Map.put(axes, id, %{axis | id: id}), dirty: mark(:frame, chart.dirty)}
  end

  @doc "Sets the chart title."
  def set_title(%__MODULE__{} = chart, title) do
    %{chart | title: title, dirty: mark(:frame, chart.dirty)}
  end

  @doc "Applies a viewport (zoom/pan state)."
  def set_viewport(%__MODULE__{} = chart, %Viewport{} = vp) do
    %{chart | viewport: vp, dirty: mark(:geometry, chart.dirty)}
  end

  @doc """
  Sets explicit domain limits for an axis, overriding data-inferred bounds.

      Chart.set_axis_limits(chart, :x1, 0.0, 100.0)
      Chart.set_axis_limits(chart, :y1, -10.0, 50.0)
  """
  def set_axis_limits(%__MODULE__{axes: axes} = chart, axis_id, min, max)
      when is_number(min) and is_number(max) and min < max do
    axis = Map.get(axes, axis_id, %Axis{id: axis_id})
    updated_axis = %{axis | limits: {min * 1.0, max * 1.0}}
    %{chart | axes: Map.put(axes, axis_id, updated_axis), dirty: mark(:scales, chart.dirty)}
  end

  # ── Compile pipeline ──────────────────────────────────────────────────────

  @doc """
  Compiles the chart, recomputing only dirty layers.

  Dependency order: frame → scales → geometry.
  Idempotent: a clean chart is returned unchanged.
  """
  def compile(%__MODULE__{dirty: dirty} = chart) do
    chart
    |> maybe_run(:frame,    &compute_frame/1)
    |> maybe_run(:scales,   &compute_scales/1)
    |> maybe_run(:geometry, &compute_geometry/1)
    |> Map.put(:dirty, MapSet.new())
  end

  # ── Frame computation ─────────────────────────────────────────────────────

  defp compute_frame(chart) do
    Frame.compute(chart)
  end

  # ── Scale computation ─────────────────────────────────────────────────────

  defp compute_scales(%__MODULE__{axes: axes, datasets: datasets, canvas: canvas, frame: frame} = chart) do
    updated_axes =
      Enum.reduce(axes, %{}, fn {id, axis}, acc ->
        axis = infer_and_set_scale(axis, id, datasets, canvas)
        axis = Axis.compute_tick_labels(axis)
        Map.put(acc, id, axis)
      end)

    updated_frame = Frame.compute_tick_pixels(frame, updated_axes)

    # Build data→pixel transform matrices for each unique (x_axis, y_axis) pair
    series_axis_pairs =
      datasets
      |> Enum.map(fn ds -> {Map.get(ds, :x_axis_id, :x1), Map.get(ds, :y_axis_id, :y1)} end)
      |> Enum.uniq()

    transforms =
      Enum.reduce(series_axis_pairs, %{}, fn {x_id, y_id}, acc ->
        x_scale = updated_axes[x_id] && updated_axes[x_id].scale
        y_scale = updated_axes[y_id] && updated_axes[y_id].scale

        if x_scale && y_scale do
          vp_matrix = Viewport.to_matrix(chart.viewport)
          transform = Scale.data_to_pixel(x_scale, y_scale, updated_frame.plot, vp_matrix)
          Map.put(acc, {x_id, y_id}, transform)
        else
          acc
        end
      end)

    updated_frame = Frame.put_transforms(updated_frame, transforms)

    %{chart | axes: updated_axes, frame: updated_frame}
  end

  defp infer_and_set_scale(%Axis{limits: {min, max}} = axis, _axis_id, _datasets, _canvas) do
    %{axis | scale: Scale.axis_scale(min, max, axis.scale_type)}
  end

  defp infer_and_set_scale(axis, axis_id, datasets, canvas) do
    column =
      case axis.dimension do
        :x -> collect_column(datasets, :x, axis_id, :x_axis_id)
        :y -> collect_column(datasets, :y, axis_id, :y_axis_id)
        :z -> collect_column(datasets, :z, axis_id, :z_axis_id)
      end

    if is_nil(column) or Nx.size(column) == 0 do
      axis
    else
      Axis.set_scale(axis, column, origin_at_zero: canvas.origin_at_zero)
    end
  end

  defp collect_column(datasets, field, axis_id, id_field) do
    tensors =
      datasets
      |> Enum.filter(fn ds -> Map.get(ds, id_field, default_axis_id(field)) == axis_id end)
      |> Enum.map(&Map.get(&1, field))
      |> Enum.reject(&is_nil/1)

    case tensors do
      [] -> nil
      [single] -> single
      many -> Nx.concatenate(many)
    end
  end

  defp default_axis_id(:x), do: :x1
  defp default_axis_id(:y), do: :y1
  defp default_axis_id(:z), do: :z1

  # ── Geometry computation ──────────────────────────────────────────────────

  defp compute_geometry(%__MODULE__{type: type, datasets: datasets, frame: frame} = chart) do
    module = chart_module(type)

    geometry =
      datasets
      |> Enum.with_index()
      |> Enum.map(fn {ds, idx} ->
        color = ds.color || Enum.at(@default_colors, rem(idx, length(@default_colors)))
        ds = %{ds | color: color}
        x_id = Map.get(ds, :x_axis_id, :x1)
        y_id = Map.get(ds, :y_axis_id, :y1)
        transform = get_in(frame.transforms, [{x_id, y_id}])

        ds_with_lod = apply_level_of_detail(ds, frame)
        module.to_geometry(ds_with_lod, transform, frame)
      end)

    %{chart | geometry: geometry}
  end

  defp apply_level_of_detail(%Dataset{x: x, y: y} = ds, frame)
       when not is_nil(x) and not is_nil(y) do
    pixel_w = frame.plot[2] |> Nx.to_number() |> trunc()

    if Nx.size(x) > pixel_w * 2 do
      {new_x, new_y} = Stat.level_of_detail(x, y, pixel_w)
      %{ds | x: new_x, y: new_y}
    else
      ds
    end
  end

  defp apply_level_of_detail(ds, _frame), do: ds

  # ── Dirty tracking ────────────────────────────────────────────────────────

  defp maybe_run(%__MODULE__{dirty: dirty} = chart, key, fun) do
    if MapSet.member?(dirty, key), do: fun.(chart), else: chart
  end

  defp mark(:data, dirty),
    do: dirty |> MapSet.put(:scales) |> MapSet.put(:geometry)

  defp mark(:frame, dirty),
    do: dirty |> MapSet.put(:frame) |> MapSet.put(:scales) |> MapSet.put(:geometry)

  defp mark(:scales, dirty),
    do: dirty |> MapSet.put(:scales) |> MapSet.put(:geometry)

  defp mark(:geometry, dirty),
    do: MapSet.put(dirty, :geometry)

  # ── Chart type dispatch ───────────────────────────────────────────────────

  defp chart_module(:line),        do: Matplotex.Chart.Line
  defp chart_module(:bar),         do: Matplotex.Chart.Bar
  defp chart_module(:scatter),     do: Matplotex.Chart.Scatter
  defp chart_module(:area),        do: Matplotex.Chart.Area
  defp chart_module(:histogram),   do: Matplotex.Chart.Histogram
  defp chart_module(:pie),         do: Matplotex.Chart.Pie
  defp chart_module(:donut),       do: Matplotex.Chart.Donut
  defp chart_module(:heatmap),     do: Matplotex.Chart.Heatmap
  defp chart_module(:box),         do: Matplotex.Chart.Box
  defp chart_module(:violin),      do: Matplotex.Chart.Violin
  defp chart_module(:bubble),      do: Matplotex.Chart.Bubble
  defp chart_module(:radar),       do: Matplotex.Chart.Radar
  defp chart_module(:candlestick), do: Matplotex.Chart.Candlestick
  defp chart_module(:waterfall),   do: Matplotex.Chart.Waterfall
  defp chart_module(:funnel),      do: Matplotex.Chart.Funnel
  defp chart_module(:step),        do: Matplotex.Chart.Step
  defp chart_module(:spline),      do: Matplotex.Chart.Spline
  defp chart_module(type),         do: raise(ArgumentError, "Unknown chart type: #{type}")

  @doc "Returns the list of all supported chart type atoms."
  def supported_types do
    ~w(line bar scatter area histogram pie donut heatmap box violin
       bubble radar candlestick waterfall funnel step spline)a
  end
end
