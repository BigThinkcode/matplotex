defmodule Matplotex.Figure.Areal do
  @moduledoc false
  alias Matplotex.Figure.Areal.Ticker
  alias Matplotex.Utils.Algebra
  alias Matplotex.Figure.Dataset
  alias Matplotex.Figure.TwoD
  @callback create(struct(), any(), keyword()) :: struct()
  @callback materialize(struct()) :: struct()
  @callback with_legend_handle(struct(), struct()) :: struct()
  @optional_callbacks with_legend_handle: 2
  defmacro __using__(_) do
    quote do
      @behaviour Matplotex.Figure.Areal
      alias Matplotex.Figure.TwoD
      alias Matplotex.Figure.Dimension
      alias Matplotex.Figure.Coords
      alias Matplotex.Figure.Text

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
      alias Matplotex.Figure.Areal.Region
      alias Matplotex.Figure.RcParams
      @default_tick_minimum 0
      @zero_to_move 0
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

      def add_ticks(
            %__MODULE__{tick: tick, size: {width, height} = size} = axes,
            {key, {_min, _max} = lim}
          ) do
        number_of_ticks =
          if key == :x do
            ceil(width)
          else
            ceil(height)
          end

        {ticks, lim} = Ticker.generate_ticks(lim, number_of_ticks)

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
        |> Cast.cast_legends()
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
      # For stacked bar chart the flattening supposed to be the sumation of yaxis data
      def flatten_for_data(datasets, nil), do: flatten_for_data(datasets)
      def flatten_for_data([%{x: x, y: y}| _datasets], bottom) do

      y= bottom
        |> Kernel.++([y])
        |> Nx.tensor(names: [:x, :y])
        |> Nx.sum(axes: [:x])
        |> Nx.to_list()
      {x, y}
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
      def hide_legend(%__MODULE__{} = axes) do
        %__MODULE__{axes | show_legend: false}
      end

      def set_frame_size(%__MODULE__{} = axes, frame_size) do
        %__MODULE__{axes | size: frame_size}
      end

      def process_concurrently(transformed, concurrency, args) do
        chunk_size = div(length(transformed), concurrency)

        transformed
        |> Enum.chunk_every(chunk_size)
        |> Task.async_stream(fn part ->
          args = [part | args]
          apply(__MODULE__, :capture, args)
        end)
        |> Enum.reduce([], fn {:ok, elements}, acc ->
          acc ++ elements
        end)
      end

      def set_region_title(
            %Figure{
              axes:
                %{
                  title: title,
                  region_x: %Region{width: region_x_width},
                  region_y: %Region{height: region_y_height} = region_y,
                  region_title: region_title,
                  size: {_f_width, _f_height},
                  border: {lx, _by, _, ty}
                } = axes,
              rc_params: %RcParams{title_font: title_font}
            } = figure
          ) do
        space_for_title = Lead.height_required_for_text(title_font, title)

        {x_region_title, y_region_title} =
          Algebra.transform_given_point(@zero_to_move, -space_for_title, lx, ty)

        %Figure{
          figure
          | axes: %{
              axes
              | region_title: %Region{
                  region_title
                  | x: x_region_title,
                    y: y_region_title + space_for_title,
                    width: region_x_width,
                    height: space_for_title
                },
                region_y: %Region{
                  region_y
                  | height: region_y_height - space_for_title
                }
            }
        }
      end

      def set_region_title(figure), do: figure

      def set_region_legend(
            %Figure{
              axes: %{
                show_legend: true
              }
            } = figure
          ) do
        configure_region_legend(figure)
      end

      def set_region_legend(
            %Figure{
              axes: %{
                cmap: cmap
              }
            } = figure
          )
          when not is_nil(cmap) do
        configure_region_legend(figure)
      end

      def set_region_legend(figure), do: figure

      defp configure_region_legend(
             %Figure{
               axes:
                 %{
                   region_x: %Region{width: region_x_width} = region_x,
                   region_title: %Region{height: region_title_height},
                   region_legend: region_legend,
                   size: {f_width, _f_height},
                   border: {_lx, by, rx, ty}
                 } = axes,
               rc_params: %RcParams{legend_width: legend_width}
             } = figure
           ) do
        region_legend_width = f_width * legend_width
        region_x_width_after_legend = region_x_width - region_legend_width

        {x_region_legend, y_region_legend} =
          Algebra.transform_given_point(-region_legend_width, -region_title_height, rx, ty)

        %Figure{
          figure
          | axes: %{
              axes
              | region_x: %Region{
                  region_x
                  | width: region_x_width_after_legend
                },
                region_legend: %Region{
                  region_legend
                  | x: x_region_legend,
                    y: y_region_legend,
                    width: region_legend_width,
                    height: y_region_legend - by
                }
            }
        }
      end

      def set_region_content(
            %Figure{
              axes:
                %{
                  region_x: %Region{x: x_region_x, width: region_x_width},
                  region_y: %Region{y: y_region_y, height: region_y_height},
                  region_content: region_content
                } = axes
            } = figure
          ) do
        %Figure{
          figure
          | axes: %{
              axes
              | region_content: %Region{
                  region_content
                  | x: x_region_x,
                    y: y_region_y,
                    width: region_x_width,
                    height: region_y_height
                }
            }
        }
      end

      def set_region_content(figure), do: figure
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
