defmodule Matplotex.BarChart.Plot do
  use Matplotex.Blueprint
  alias Matplotex.BarChart.Content
  alias Matplotex.BarChart.Bar
  alias Matplotex.BarChart.Element
  alias Matplotex.BarChart.GenerateSvg
  alias Matplotex.BarChart
  @x_data_range_start_at 0
  @y_data_range_start_at 0
  @default_margin 15
  @default_width 400
  @default_height 400
  @default_ylabel_offset 30
  @default_x_label_offset 20
  @tick_length 5
  @default_color_palette "#5cf"
  @content_fields [:label_offset, :label_suffix, :y_max, :color_palette]
  @stroke_grid "#ddd"

  @stroke_width_grid 1

  @impl true
  @spec new(module(), BarChart.params()) :: {Matplotex.BarChart.t(), map()}
  def new(module, params) do
    {params, content_params} =
      params
      |> validate_params()
      |> generate_chart_params()
      |> segregate_content(@content_fields)

    {struct(module, params), content_params}
  end

  @impl true
  def set_content(
        {%BarChart{
           dataset: %{y: y_dataset},
           size: %{width: width, height: height},
           margin: %{x_margin: x_margin, y_margin: y_margin}
         } = chartset,
         %{
           label_offset: %{x: x_label_offset, y: y_label_offset} = label_offset,
           label_suffix: label_sufix,
           y_max: y_max,
           color_palette: color_palette
         }}
      ) do
    dlength =
      y_dataset
      |> List.flatten()
      |> length()

    content_width = width - y_label_offset - 2 * x_margin
    usize = content_width / dlength
    umargin = usize * 0.1
    u_width = usize - umargin

    %{
      chartset
      | content: %Content{
          width: content_width,
          height: height - x_label_offset - 2 * y_margin,
          x: y_margin + y_label_offset,
          y: x_margin + x_label_offset,
          u_margin: umargin,
          u_width: u_width,
          tick_length: @tick_length,
          label_offset: label_offset,
          label_suffix: label_sufix,
          y_max: y_max,
          color_palette: color_palette
        }
    }
  end

  @impl true
  def add_elements(chartset) do
    chartset
    |> add_axis_lines()
    |> add_grid_lines()
    |> add_bars_and_labels()
  end

  defp generate_chart_params({:ok, params}) do
    y_data = Map.get(params, "dataset")
    x_data = params |> Map.get("x_labels") |> generate_x_data()
    dataset = %{x: x_data, y: y_data}

    label_offset = label_offset(params)
    {labels, y_max, y_scale, label_suffix} = generate_labels(params, y_data)

    %{
      color_palette: Map.get(params, "color_palette", @default_color_palette),
      dataset: dataset,
      label_offset: label_offset,
      label_suffix: label_suffix,
      label: labels,
      margin: %{
        x_margin: Map.get(params, "x_margin", @default_margin),
        y_margin: Map.get(params, "x_margin", @default_margin)
      },
      size: %{
        width: Map.get(params, "width", @default_width),
        height: Map.get(params, "height", @default_height)
      },
      y_max: y_max,
      scale: %{y: y_scale}
    }
  end

  defp label_offset(params) do
    x_label_offset = Map.get(params, "x_label_offset", @default_x_label_offset)
    y_label_offset = Map.get(params, "y_label_offset", @default_ylabel_offset)
    %{x: x_label_offset, y: y_label_offset}
  end

  defp generate_x_data([x_label | _] = x_labels) when is_number(x_label), do: x_labels

  defp generate_x_data([x_label | _] = x_labels) when is_binary(x_label) do
    @x_data_range_start_at
    |> Range.new(length(x_labels))
    |> Range.to_list()
  end

  defp generate_labels(params, y_data) do
    y_label_suffix = Map.get(params, "y_label_suffix")

    y_scale = Map.get(params, "y_scale")
    y_max = Enum.max(y_data)
    y_max = calculate_y_max(y_max, y_scale)

    y_labels =
      @y_data_range_start_at..div(y_max, y_scale)
      |> Enum.map(fn value -> "#{value * y_scale}#{y_label_suffix}" end)

    {%{x: Map.get(params, "x_labels"), y: y_labels}, y_max, y_scale, %{x: "", y: y_label_suffix}}
  end

  # TODO: Make it common to all
  defp add_axis_lines(
         %BarChart{
           content: %Content{x: content_x, height: height},
           size: %{width: width}
         } = chartset
       ) do
    yaxis = %Line{type: "axis.xaxis", x1: content_x, y1: height, x2: content_x, y2: 0}
    y = height

    xaxis = %Line{
      type: "axis.xaxis",
      x1: content_x,
      y1: y,
      x2: width,
      y2: y
    }

    element = %Element{axis: [xaxis, yaxis]}

    %{chartset | element: element}
  end

  # TODO: Try to make it a common function to all plots turn grid on or off
  defp add_grid_lines(
         %BarChart{
           content: %Content{
             height: content_height,
             width: content_width,
             x: cx,
             label_suffix: %{y: y_label_suffix},
             label_offset: %{y: y_label_offset},
             y_max: y_max,
             tick_length: tick_length
           },
           size: %{width: grid_x2},
           element: element,
           scale: %{y: y_scale},
           dataset: %{y: dataset}
         } = chartset
       ) do
    grids = (y_max / y_scale) |> trunc()

    {grid_lines, ticks} =
      1..grids
      |> Enum.map(fn grid ->
        y_scale = grid * y_scale

        {_x, y} =
          transformation(
            0,
            y_scale,
            {0, length(dataset)},
            {0, y_max},
            content_width,
            content_height
          )

        # TODO: Take font details from input
        {
          %Line{
            type: "grid.xaxis",
            x1: cx,
            x2: grid_x2,
            y1: y,
            y2: y,
            stroke: @stroke_grid,
            stroke_width: @stroke_width_grid
          },
          %Tick{
            label: %Label{
              type: "tick.yaxis",
              x: cx - y_label_offset,
              y: y,
              text: "#{y_scale}#{y_label_suffix}"
            },
            tick_line: %Line{type: "tick.yaxis", x1: cx, x2: cx - tick_length, y1: y, y2: y}
          }
        }
      end)
      |> Enum.unzip()

    %{chartset | element: %Element{element | ticks: ticks, grid: grid_lines}}
  end

  defp add_bars_and_labels(
         %BarChart{
           dataset: %{y: dataset},
           content: %Content{width: width, height: height, y_max: ymax},
           element: %Element{ticks: ticks} = elements
         } = chartset
       ) do
    {bars, xticks} =
      dataset
      |> Enum.with_index()
      |> transform_dataset(
        {0, length(dataset)},
        {0, ymax},
        width,
        height
      )
      |> generate_elements(chartset)
      |> Enum.unzip()

    %{
      chartset
      | element: %{elements | bars: bars, ticks: ticks ++ xticks}
    }
  end

  def transform_dataset(dataset, xminmax, yminmax, width, height) do
    Enum.map(dataset, fn {y, x} ->
      transformation(x, y, xminmax, yminmax, width, height)
    end)
  end

  defp generate_elements(transformed, %BarChart{
         label: %{x: xlabels},
         content:
           %Content{
             height: height,
             u_width: u_width,
             color_palette: color,
             label_offset: %{x: x_label_offset}
           } = content
       }) do
    transformed
    |> Enum.zip(xlabels)
    |> Enum.map(fn {{x, y}, label} ->
      bar_height = Content.bar_height(y, content)

      {%Bar{
         x: Content.transform({:x, x}, content),
         y: y,
         width: u_width,
         height: bar_height,
         color: color
       },
       %Tick{
         label: %Label{
           type: "tick.xaxis",
           x: Content.transform({:x, x}, content),
           y: height + x_label_offset,
           font_size: "16pt",
           font_weight: "normal",
           text: label
         },
         tick_line: %Line{
           x1: Content.x_axis_tick(x, content),
           y1: height,
           x2: Content.x_axis_tick(x, content),
           y2: height + @tick_length,
           type: "tick.xaxis"
         }
       }}
    end)
  end

  @impl true
  def generate_svg(graphset) do
    GenerateSvg.generate(graphset, "")
  end

  defp calculate_y_max(y_max, y_scale) do
    if rem(y_max, y_scale) == 0 do
      y_max
    else
      y_max - rem(y_max, y_scale) + y_scale
    end
  end
end
