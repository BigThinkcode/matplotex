defmodule Matplotex.Frame do
  @moduledoc """
  Pixel layout for one chart panel — all regions as Nx tensors.

  Every region is `Nx.tensor([x, y, width, height], type: :f64)`.
  Every coordinate arithmetic operation goes through Nx — no plain
  Elixir `+` / `-` is used for pixel-space math.

  ## Compute pipeline (all Nx)

  1. `canvas_px`  — figsize × dpi via `Nx.multiply`
  2. `margin_box` — four edge corners via `Nx.multiply`
  3. Strip sizes  — per-axis tick+label widths/heights as Nx scalars,
                    summed with `Nx.stack |> Nx.sum`
  4. `plot`       — margin corners minus strip totals via `Nx.add`
  5. Axis regions — strips placed adjacent to plot via `Nx.stack`
  6. Tick pixels  — `Nx.linspace` from plot edges per axis

  Consumers extract scalars with `Nx.to_number/1` only at SVG boundary.
  """

  alias Matplotex.Canvas

  @type region :: Nx.Tensor.t()

  @type t :: %__MODULE__{
          canvas_px: Nx.Tensor.t() | nil,
          plot: region() | nil,
          title: region() | nil,
          legend: region() | nil,
          axis_regions: %{atom() => region()},
          tick_pixels: %{atom() => Nx.Tensor.t()},
          transforms: %{{atom(), atom()} => Nx.Tensor.t()}
        }

  defstruct canvas_px: nil,
            plot: nil,
            title: nil,
            legend: nil,
            axis_regions: %{},
            tick_pixels: %{},
            transforms: %{}

  @tick_mark_px 6.0
  @tick_gap_px 4.0
  @char_width_ratio 0.6
  @fallback_label_chars 5

  # ── Main compute ──────────────────────────────────────────────────────────

  @doc """
  Computes the full pixel layout for `chart` via Nx.

  `chart` must have: `canvas`, `axes`, `title` (may be nil).
  Returns an updated chart with `frame` populated.
  """
  def compute(%{canvas: canvas, axes: axes} = chart) do
    title = Map.get(chart, :title)

    # 1. Canvas pixels
    {cw, ch} = Canvas.to_pixels(canvas)
    canvas_px = Nx.tensor([cw, ch], type: :f64)

    # 2. Margin box corners [left, top, right, bottom]
    m = canvas.margin
    canvas_sides = Nx.tensor([cw, ch, cw, ch], type: :f64)
    margin_factors = Nx.tensor([m, m, 1.0 - m, 1.0 - m], type: :f64)
    margin_box = Nx.multiply(canvas_sides, margin_factors)

    # 3. Title height
    title_h_val = if title, do: canvas.title_font_size * 2.0, else: 0.0
    title_h = Nx.tensor(title_h_val, type: :f64)

    # 4. Strip totals per side (all Nx)
    axis_list = Map.values(axes)
    by_side = Enum.group_by(axis_list, & &1.position)

    total_left   = sum_strips(Map.get(by_side, :left,   []), canvas, :width)
    total_right  = sum_strips(Map.get(by_side, :right,  []), canvas, :width)
    total_bottom = sum_strips(Map.get(by_side, :bottom, []), canvas, :height)
    total_top    = sum_strips(Map.get(by_side, :top,    []), canvas, :height)

    # 5. Plot corners from margin box
    # [plot_x, plot_y, plot_right, plot_bottom]
    insets = Nx.stack([
      total_left,
      Nx.add(title_h, total_top),
      Nx.negate(total_right),
      Nx.negate(total_bottom)
    ])
    plot_corners = Nx.add(margin_box, insets)
    plot = corners_to_xywh(plot_corners)

    # 6. Title and legend regions
    title_region = Nx.stack([
      margin_box[0],
      margin_box[1],
      Nx.subtract(margin_box[2], margin_box[0]),
      title_h
    ])
    legend_region = Nx.stack([margin_box[2], plot[1], Nx.tensor(0.0, type: :f64), plot[3]])

    # 7. Axis strip regions (stacking outward)
    axis_regions =
      (position_strips(Map.get(by_side, :left,   []), :left,   plot, canvas) ++
       position_strips(Map.get(by_side, :right,  []), :right,  plot, canvas) ++
       position_strips(Map.get(by_side, :bottom, []), :bottom, plot, canvas) ++
       position_strips(Map.get(by_side, :top,    []), :top,    plot, canvas))
      |> Map.new()

    frame = %__MODULE__{
      canvas_px:    canvas_px,
      plot:         plot,
      title:        title_region,
      legend:       legend_region,
      axis_regions: axis_regions,
      tick_pixels:  %{},
      transforms:   %{}
    }

    %{chart | frame: frame}
  end

  @doc """
  Computes tick pixel positions for all axes after scales are finalized.

  Called by the chart compiler after `compute_scales/1`, because tick
  positions depend on the domain which isn't known during `compute/1`.
  Returns updated frame.
  """
  def compute_tick_pixels(%__MODULE__{plot: plot} = frame, axes) do
    tick_pixels =
      Enum.reduce(axes, %{}, fn {axis_id, axis}, acc ->
        case tick_pixels_for(axis, plot) do
          nil    -> acc
          tensor -> Map.put(acc, axis_id, tensor)
        end
      end)

    %{frame | tick_pixels: tick_pixels}
  end

  @doc """
  Stores pre-computed transforms in the frame.
  """
  def put_transforms(%__MODULE__{} = frame, transforms) do
    %{frame | transforms: transforms}
  end

  # ── Strip measurement ─────────────────────────────────────────────────────

  defp strip_size(%{position: pos} = axis, canvas) when pos in [:bottom, :top] do
    tick_h = Nx.tensor(
      canvas.tick_font_size * 1.5 + @tick_mark_px + @tick_gap_px,
      type: :f64
    )
    label_h =
      if axis.label,
        do: Nx.tensor(canvas.label_font_size * 1.8, type: :f64),
        else: Nx.tensor(0.0, type: :f64)
    Nx.add(tick_h, label_h)
  end

  defp strip_size(%{position: pos} = axis, canvas) when pos in [:left, :right] do
    chars = max_label_chars(axis)
    tick_w = Nx.tensor(
      chars * canvas.tick_font_size * @char_width_ratio + @tick_mark_px + @tick_gap_px,
      type: :f64
    )
    label_w =
      if axis.label,
        do: Nx.tensor(canvas.label_font_size * 1.8, type: :f64),
        else: Nx.tensor(0.0, type: :f64)
    Nx.add(tick_w, label_w)
  end

  defp strip_size(_axis, _canvas), do: Nx.tensor(0.0, type: :f64)

  defp sum_strips([], _canvas, _dim), do: Nx.tensor(0.0, type: :f64)

  defp sum_strips(axes, canvas, _dim) do
    axes
    |> Enum.map(&strip_size(&1, canvas))
    |> Nx.stack()
    |> Nx.sum()
  end

  # ── Strip positioning ─────────────────────────────────────────────────────

  defp position_strips(axes, side, plot, canvas) do
    initial = case side do
      :left   -> plot[0]
      :right  -> Nx.add(plot[0], plot[2])
      :bottom -> Nx.add(plot[1], plot[3])
      :top    -> plot[1]
    end

    {pairs, _} =
      Enum.map_reduce(axes, initial, fn axis, cursor ->
        size = strip_size(axis, canvas)

        region = case side do
          :left   -> Nx.stack([Nx.subtract(cursor, size), plot[1], size, plot[3]])
          :right  -> Nx.stack([cursor, plot[1], size, plot[3]])
          :bottom -> Nx.stack([plot[0], cursor, plot[2], size])
          :top    -> Nx.stack([plot[0], Nx.subtract(cursor, size), plot[2], size])
        end

        next = case side do
          :left   -> Nx.subtract(cursor, size)
          :right  -> Nx.add(cursor, size)
          :bottom -> Nx.add(cursor, size)
          :top    -> Nx.subtract(cursor, size)
        end

        {{axis.id, region}, next}
      end)

    pairs
  end

  # ── Tick pixel computation ────────────────────────────────────────────────

  defp tick_pixels_for(%{scale: nil}, _plot), do: nil
  defp tick_pixels_for(%{scale: %{domain_min: nil}}, _plot), do: nil

  defp tick_pixels_for(%{dimension: :x, tick_count: n}, plot) do
    Nx.linspace(plot[0], Nx.add(plot[0], plot[2]), n: n)
  end

  defp tick_pixels_for(%{tick_count: n}, plot) do
    # y/z: domain_min → bottom, domain_max → top (SVG y-flip)
    Nx.linspace(Nx.add(plot[1], plot[3]), plot[1], n: n)
  end

  # ── Helpers ───────────────────────────────────────────────────────────────

  # [left, top, right, bottom] → [x, y, w, h]
  defp corners_to_xywh(corners) do
    Nx.stack([
      corners[0],
      corners[1],
      Nx.subtract(corners[2], corners[0]),
      Nx.subtract(corners[3], corners[1])
    ])
  end

  defp max_label_chars(%{scale: nil}), do: @fallback_label_chars
  defp max_label_chars(%{scale: %{domain_min: nil}}), do: @fallback_label_chars

  defp max_label_chars(%{scale: scale}) do
    len_min = scale.domain_min |> format_number() |> String.length()
    len_max = scale.domain_max |> format_number() |> String.length()
    max(len_min, len_max)
  end

  defp format_number(value) when is_float(value) do
    if Float.floor(value) == value,
      do: Integer.to_string(trunc(value)),
      else: Float.to_string(Float.round(value, 3))
  end

  defp format_number(value) when is_integer(value), do: Integer.to_string(value)
end
