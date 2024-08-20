# defmodule Matplotex.BarChart.Plot do
#   alias Matplotex.BarChart.Content
#   alias Matplotex.BarChart.Element
#   use Matplotex.Blueprint

#   @x_data_range_start_at 0
#   @y_data_range_start_at 0
#   @default_margin 15
#   @default_ylabel_offset 30
#   @default_x_label_offset 20
#   @default_width 400
#   @default_height 400
#   @default_color_palette ["#5cf"]
#   @tick_length 5
#   @required_fields [
#     "dataset",
#     "x_labels"
#   ]

#   @type params() :: %{
#           dataset: list(),
#           x_labels: list(),
#           color_palette: String.t() | list(),
#           width: number(),
#           margin: number(),
#           height: number(),
#           y_scale: number(),
#           y_label_prefix: String.t(),
#           y_label_offset: number(),
#           x_label_offset: number()
#         }

#   @doc """
#   New accepts a set of params and creates a chart data

#   %{
#       "dataset" => [44, 56, 67, 67, 89, 14, 57, 33, 59, 67, 90, 34],
#       "x_labels" => ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
#       "color_palette" =>  ["#5cf"],
#       "width" => 700,
#       "margin" => 15,
#       "height" => 300,
#       "y_scale" => 20,
#       "y_label_prefix" => "K",
#       "y_label_offset" => 40,
#       "x_label_offset" => 20
#     }

#   """
#   @impl true
#   def new(params) do
#     params
#     |> validate_params()
#     |> generate_chart_params()
#     |> Chart.new()
#   end

#   @impl true
#   def validate_params(params) do
#     if valid_keys?(params) do
#       params
#     else
#       {:error, "Invalid input, input should include keys: #{inspect(@required_fields)}"}
#     end
#   end

#   @impl true
#   def set_content(
#         %Chart{
#           dataset: %{y: y_dataset},
#           width: width,
#           height: height,
#           label_offset: %{x: x_label_offset, y: y_label_offset},
#           margin: margin
#         } = chartset
#       ) do
#     dlength =
#       y_dataset
#       |> List.flatten()
#       |> length()

#     content_width = width - y_label_offset - 2 * margin
#     usize = content_width / dlength
#     umargin = usize * 0.1
#     u_width = usize - umargin

#     %{
#       chartset
#       | content: %Content{
#           width: content_width,
#           height: height - x_label_offset - 2 * margin,
#           x: margin + y_label_offset,
#           y: margin + x_label_offset,
#           u_margin: umargin,
#           u_width: u_width,
#           tick_length: @tick_length
#         }
#     }
#   end

#   @impl true
#   def add_elements(chartset) do
#     chartset
#     |> add_axis_lines()
#     |> add_grid_lines()
#     |> add_bars_and_labels()
#   end

#   defp generate_chart_params({:error, _message} = error), do: error

#   defp generate_chart_params(params) do
#     y_data = Map.get(params, "dataset")
#     x_data = params |> Map.get("x_labels") |> generate_x_data()
#     dataset = %{x: x_data, y: y_data}

#     label_offset = label_offset(params)
#     {labels, y_max, y_scale, label_prefix} = generate_labels(params, y_data)

#     %{
#       color_palette: Map.get(params, "color_palette", @default_color_palette),
#       dataset: dataset,
#       height: Map.get(params, "height", @default_height),
#       label_offset: label_offset,
#       label_prefix: label_prefix,
#       labels: labels,
#       margin: Map.get(params, "margin", @default_margin),
#       show_axis_lines: Map.get(params, "show_axis_lines", true),
#       show_grid_lines: Map.get(params, "show_grid_lines", true),
#       type: __MODULE__,
#       width: Map.get(params, "width", @default_width),
#       y_max: y_max,
#       y_scale: y_scale
#     }
#   end

#   defp generate_x_data([x_label | _] = x_labels) when is_number(x_label), do: x_labels

#   defp generate_x_data([x_label | _] = x_labels) when is_binary(x_label) do
#     @x_data_range_start_at
#     |> Range.new(length(x_labels))
#     |> Range.to_list()
#   end

# defp generate_labels(params, y_data) do
#   y_label_prefix = Map.get(params, "y_label_prefix")

#   y_scale = Map.get(params, "y_scale")
#   y_max = Enum.max(y_data)
#   y_max = calculate_y_max(y_max, y_scale)

#   y_labels =
#     @y_data_range_start_at..div(y_max, y_scale)
#     |> Enum.map(fn value -> "#{value * y_scale}#{y_label_prefix}" end)

#   {%{x: Map.get(params, "x_labels"), y: y_labels}, y_max, y_scale, %{x: "", y: y_label_prefix}}
# end

#   defp calculate_y_max(y_max, y_scale) do
#     if rem(y_max, y_scale) == 0 do
#       y_max
#     else
#       y_max - rem(y_max, y_scale) + y_scale
#     end
#   end

#   defp label_offset(params) do
#     x_label_offset = Map.get(params, "x_label_offset", @default_x_label_offset)
#     y_label_offset = Map.get(params, "y_label_offset", @default_ylabel_offset)
#     %{x: x_label_offset, y: y_label_offset}
#   end

#   defp add_axis_lines(
#          %Chart{
#            content: %Content{x: content_x, height: height},
#            width: width
#          } = chartset
#        ) do
#     yaxis = %Line{type: "axis.xaxis", x1: content_x, y1: height, x2: content_x, y2: 0}
#     y = height

#     xaxis = %Line{
#       type: "axis.xaxis",
#       x1: content_x,
#       y1: y,
#       x2: width,
#       y2: y
#     }

#     %{chartset | axis_lines: [xaxis, yaxis]}
#   end

#   defp add_grid_lines(
#          %Chart{
#            content: %Content{height: content_height, width: content_width, x: cx},
#            y_max: y_max,
#            y_scale: y_scale,
#            dataset: %{y: dataset},
#            label_prefix: %{y: y_label_prefix},
#            label_offset: %{y: y_label_offset}
#          } = chartset
#        ) do
#     grids = (y_max / y_scale) |> trunc()

#     {grid_lines, {labels, ticks}} =
#       1..grids
#       |> Enum.map(fn grid ->
#         y_scale = grid * y_scale

#         {_x, y} =
#           transformation(
#             0,
#             y_scale,
#             {0, length(dataset)},
#             {0, y_max},
#             content_width,
#             content_height
#           )

#         {%Line{type: "grid.xaxis", x1: cx, x2: content_width, y1: y, y2: y},
#          {%Label{
#             axis: "labels.yaxis",
#             x: cx - y_label_offset,
#             y: y,
#             font_size: "16pt",
#             font_weight: "normal",
#             text: "#{y_scale}#{y_label_prefix}"
#           }, %Line{type: "tick.yaxis", x1: cx, x2: cx - @tick_length, y1: y, y2: y}}}
#       end)
#       |> Enum.unzip()
#       |> then(fn {grid_lines, labels} -> {grid_lines, Enum.unzip(labels)} end)

#     %{chartset | elements: %Element{ticks: ticks, labels: labels}, grid_lines: grid_lines}
#   end

#   defp add_bars_and_labels(
#          %Chart{
#            dataset: %{y: dataset},
#            content: %Content{width: width, height: height},
#            y_max: ymax,
#            elements: %Element{labels: labels, ticks: ticks} = elements
#          } = chartset
#        ) do
#     {bars, {xlabels, xticks}} =
#       dataset
#       |> Enum.with_index()
#       |> transform_dataset(
#         width,
#         height,
#         {0, length(dataset)},
#         {0, ymax},
#         []
#       )
#       |> generate_bars(chartset)

#     %{
#       chartset
#       | elements: %{elements | bars: bars, labels: labels ++ xlabels, ticks: ticks ++ xticks}
#     }
#   end

#   def transform_dataset([{y, x} | dataset], width, height, xminmax, yminmax, transformed) do
#     transforms = transformation(x, y, xminmax, yminmax, width, height)

#     transform_dataset(
#       dataset,
#       width,
#       height,
#       xminmax,
#       yminmax,
#       transformed ++ [transforms]
#     )
#   end

#   def transform_dataset([], _width, _height, _xminmax, _yminmax, transformed),
#     do: transformed

#   defp generate_bars(transformed, %Chart{
#          labels: %{x: xlabels},
#          color_palette: color,
#          label_offset: %{x: x_label_offset},
#          content: %Content{height: height, u_width: u_width} = content
#        }) do
#     transformed
#     |> Enum.zip(xlabels)
#     |> Enum.map(fn {{x, y}, label} ->
#       bar_height = Content.bar_height(y, content)

#       {%Bar{
#          x: Content.transform({:x, x}, content),
#          y: y,
#          width: u_width,
#          height: bar_height,
#          color: color
#        },
#        {%Label{
#           axis: "labels.xaxis",
#           x: Content.transform({:x, x}, content),
#           y: height + x_label_offset,
#           font_size: "16pt",
#           font_weight: "normal",
#           text: label
#         },
#         %Line{
#           x1: Content.x_axis_tick(x, content),
#           y1: height,
#           x2: Content.x_axis_tick(x, content),
#           y2: height + @tick_length,
#           type: "tick.xaxis"
#         }}}
#     end)
#     |> Enum.unzip()
#     |> then(fn {bars, labels} -> {bars, Enum.unzip(labels)} end)
#   end

#   defp valid_keys?(params) do
#     @required_fields in Map.keys(params)
#   end
# end
