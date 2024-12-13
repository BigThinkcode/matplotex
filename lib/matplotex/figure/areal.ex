defmodule Matplotex.Figure.Areal do
  alias Matplotex.Utils.Algebra
  alias Matplotex.Figure.Dataset
  alias Matplotex.Figure.TwoD
  @callback create(struct(), any(), keyword()) :: struct()
  @callback materialize(struct()) :: struct()
  @callback plotify(number(), tuple(), number(), number(), list(), atom()) :: number()
  defmacro __using__(_) do
    quote do
      @behaviour Matplotex.Figure.Areal
      alias Matplotex.Figure.TwoD
      alias Matplotex.Figure.Dimension
      alias Matplotex.Figure.Coords
      alias Matplotex.Figure.Text
      alias Matplotex.Figure.Legend

      import Matplotex.Figure.Areal, only: [transformation: 7, do_transform: 6]
      import Matplotex.Blueprint.Frame
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      alias Matplotex.Figure.Cast

      alias Matplotex.Figure.Lead
      alias Matplotex.Figure.Font
      alias Matplotex.Figure
      alias Matplotex.Figure.Dataset

      alias Matplotex.Figure.Text
      @default_tick_minimum 0
      def add_label(%__MODULE__{label: nil} = axes, {key, label}, opts) when is_binary(label) do
        label =
          Map.new()
          |> Map.put(key, label)

        # Text.create_text(label, opts))

        update_label(axes, label)
      end

      def add_label(%__MODULE__{label: ax_label} = axes, {key, label}, opts)
          when is_binary(label) do
        label = Map.put(ax_label, key, label)
        #  Text.create_text(label, opts))
        update_label(axes, label)
      end

      def add_label(_axes, _label) do
        raise Matplotex.InputError, keys: [:label], message: "Invalid input"
      end

      def add_title(axes, title, opts) when is_binary(title) do
        # title = Text.create_text(title, opts)
        %{axes | title: title, show_title: true}
      end

      def add_title(_, _) do
        raise Matplotex.InputError, keys: [:title], message: "Invalid Input"
      end

      def add_ticks(%__MODULE__{tick: tick} = axes, {key, ticks}) when is_list(ticks) do
        {ticks, lim} =
          if number_based?(ticks) do
            {ticks, Enum.min_max(ticks)}
          else
            {Enum.with_index(ticks), {@default_tick_minimum, length(ticks)}}
          end

        tick = Map.put(tick, key, ticks)

        axes
        |> set_limit({key, lim})
        |> update_tick(tick)
      end

      def add_ticks(%__MODULE__{tick: tick, size: size} = axes, {key, {_min, _max} = lim}) do
        {ticks, lim} = __MODULE__.generate_ticks(lim)

        tick = Map.put(tick, key, ticks)

        axes
        |> set_limit({key, lim})
        |> update_tick(tick)
      end

      def add_ticks(_, _) do
        raise Matplotex.InputError, keys: [:tick], message: "Invalid Input"
      end

      def hide_v_grid(axes) do
        %{axes | show_v_grid: false}
      end

      def set_limit(%__MODULE__{limit: limit} = axes, {key, {_, _} = lim}) do
        limit = Map.put(limit, key, lim)
        update_limit(axes, limit)
      end

      def set_limit(_, _) do
        raise Matplotex.InputError, keys: [:limit], message: "Invalid Input"
      end

      def add_legend(%__MODULE__{legend: nil} = axes, params) do
        legend = struct(Legend, params)
        %{axes | legend: legend}
      end

      def add_legend(%__MODULE__{legend: legend} = axes, params) do
        legend = struct(legend, params)
        %{axes | legend: legend}
      end

      def generate_xticks(%module{data: {x, _y}, tick: tick, limit: limit} = axes) do
        {xticks, xlim} =
          module.generate_ticks(x)

        tick = Map.put(tick, :x, xticks)
        limit = update_limit(limit, :x, xlim)
        %__MODULE__{axes | tick: tick, limit: limit}
      end

      def generate_yticks(%module{data: {_x, y}, tick: tick, limit: limit} = axes) do
        {yticks, ylim} =
          module.generate_ticks(y)

        tick = Map.put(tick, :y, yticks)
        limit = update_limit(limit, :y, ylim)
        %__MODULE__{axes | tick: tick, limit: limit}
      end

      defp update_limit(%TwoD{x: nil} = limit, :x, xlim) do
        %TwoD{limit | x: xlim}
      end

      defp update_limit(%TwoD{y: nil} = limit, :y, ylim) do
        %TwoD{limit | y: ylim}
      end

      defp update_limit(limit, _, _), do: limit

      def materialized_by_region(figure) do
        figure
        |> Lead.set_regions_areal()
        |> Cast.cast_xticks_by_region()
        |> Cast.cast_yticks_by_region()
        |> Cast.cast_hgrids_by_region()
        |> Cast.cast_vgrids_by_region()
        |> Cast.cast_spines_by_region()
        |> Cast.cast_label_by_region()
        |> Cast.cast_title_by_region()
      end

      defp update_tick(axes, tick) do
        %{axes | tick: tick}
      end

      defp update_label(axes, label) do
        %{axes | label: label}
      end

      defp update_limit(axes, limit) do
        %{axes | limit: limit}
      end

      def determine_numeric_value(data) when is_list(data) do
        if number_based?(data) do
          data
        else
          data_with_label(data)
        end
      end

      def flatten_for_data(datasets) do
        datasets
        |> Enum.map(fn %{x: x, y: y} -> {x, y} end)
        |> Enum.unzip()
        |> then(fn {xs, ys} ->
          {unify_data(xs), unify_data(ys)}
        end)
      end

      def unify_data(data) do
        data |> List.flatten() |> MapSet.new() |> MapSet.to_list()
      end

      defp data_with_label(data) do
        Enum.with_index(data, 1)
      end

      def number_based?(data) do
        Enum.all?(data, &is_number/1)
      end

      def min_max([{_pos, _label} | _] = ticks) do
        ticks
        |> Enum.min_max_by(fn {pos, _label} -> pos end)
        |> then(fn {{pos_min, _label_min}, {pos_max, _label_max}} -> {pos_min, pos_max} end)
      end

      def min_max(ticks) do
        Enum.min_max(ticks)
      end

      def show_legend(%__MODULE__{} = axes) do
        %__MODULE__{axes | show_legend: true}
      end

      def set_frame_size(%__MODULE__{} = axes, frame_size) do
        %__MODULE__{axes | size: frame_size}
      end
    end
  end
  def transformation({_labelx, x}, {_labely, y}, xminmax, yminmax, width, height, transition) do
    transformation(x, y, xminmax, yminmax, width, height, transition)
  end
  def transformation({_label, x}, y, xminmax, yminmax, width, height, transition) do
    transformation(x, y, xminmax, yminmax, width, height, transition)
  end

  def transformation(x, {_label, y}, xminmax, yminmax, width, height, transition) do
    transformation(x, y, xminmax, yminmax, width, height, transition)
  end


  def transformation(
        x,
        y,
        {xmin, xmax},
        {ymin, ymax},
        svg_width,
        svg_height,
        {transition_x, transition_y}
      ) do
    sx = svg_width / (xmax - xmin)
    sy = svg_height / (ymax - ymin)
    tx = transition_x - xmin * sx
    ty = transition_y - ymin * sy
    Algebra.transform_given_point(x, y, sx, sy, tx, ty)
  end

  def do_transform(%Dataset{x: x, y: y} = dataset, xlim, ylim, width, height, transition) do
    transformed =
      x
      |> Enum.zip(y)
      |> Enum.map(fn {x, y} ->

        x
        |> transformation(y, xlim, ylim, width, height, transition)
        |> Algebra.flip_y_coordinate()
      end)
    %Dataset{dataset | transformed: transformed}
  end
end
