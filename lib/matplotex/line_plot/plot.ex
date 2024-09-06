defmodule Matplotex.LinePlot.Plot do
  alias Matplotex.LinePlot.Element
  use Matplotex.Blueprint
  alias Matplotex.LinePlot
  alias Matplotex.LinePlot.Content
  alias Matplotex.Element.AxisLine
  alias Matplotex.Element.GridLine
  alias Matplotex.Element.Line
  @defualt_size 400
  @default_margin 15

  @content_fields [:label_offset, :x_max, :y_max, :line_width, :color_palette]

  def new(graph, params) do
    {params, content_params} =
      params
      |>validate_params()
      |> generate_chart_params()
      |>segregate_content(@content_fields)
{struct(graph, params), content_params}
  end
  def set_content({%LinePlot{size: %{width: width, height: height}, margin: %{x_margin: x_margin, y_margin: y_margin}} = plotset, %{label_offset: %{x: x_label_offset, y: y_label_offset}} = content_params}) do
    content = struct(Content, content_params)
    %LinePlot{plotset | content: %Content{content | width: width - y_label_offset - 2 * x_margin, height: height - x_label_offset - 2 * y_margin, x: x_margin + y_label_offset, y: y_margin+y_label_offset}}
  end
  def add_elements(plotset) do
    plotset
    |>add_axis_lines()
    |>add_grid_lines()
    |>add_plot_lines()

  end

  def generate_svg(graphset) do

  end

  defp add_plot_lines(%LinePlot{dataset: dataset,element: element, content: %Content{color_palette: color_palette}} = plotset) do

   plot_lines =  dataset
    |> Enum.zip(color_palette)
    |> Enum.map(&generate_plot_lines(&1, plotset))
    element = %Element{element | lines: plot_lines}
    %LinePlot{plotset| element: element}
  end

  defp generate_plot_lines({color, dataset}, %LinePlot{content: %Content{x: content_x, y: content_y, width: content_width, line_width: line_width,height: content_height}}) do
    [x_minmax, y_minmax] = dataset |> Enum.with_index()|>Enum.unzip()|> Enum.map(&Enum.min_max)

    dataset
    |>Enum.with_index()
    |>Enum.reduce(%{x1: content_x, y1: content_y}, fn {x, y}, %{x1: x1, y1: y1} ->

      {x2_tr, y2_tr} = transformation(x2, y2, x_minmax, y_minmax, content_width, content_height)|> rotation(:math.pi())

     %Line{x1: , x2: "transformed x", y1: "acc y1", y2: "transformed y2", stroke: color, stroke_width: line_width }
    end )
  end


  defp add_axis_lines(plotset) do
   axis_lines =  plotset|>AxisLine.genarate_axis_lines() |>Enum.filter(fn x -> !is_nil(x) end)
   element = %Element{axis: axis_lines}
   %{plotset | element: element}
  end
  defp add_grid_lines(%LinePlot{dataset: dataset, tick: %{x: x_labels}, type: "line_chart" } = plotset) do
    x_minmax = 0..length(x_labels) |>Enum.min_max()
    y_minmax = dataset|>List.flatten()|>Enum.min_max()

    GridLine.generate_grid_lines(plotset, x_minmax, y_minmax)
  end
  defp add_grid_lines(plotset), do: plotset

  defp generate_chart_params(%{"dataset"=> _dataset}= params) do
    params = for {k, v} <- params, into: %{}, do: {String.to_atom(k), v}
    generate_chart_params(params)
  end

  defp generate_chart_params(params) do
    {size, params} = size(params)
    {margin, params} = margin(params)
    {tick, params} = tick(params)
    {label_offset, params} = label_offset(params)
    {scale, params} = scale(params)
    {x_max, y_max} = xymax(params)
    %{params | size: size, margin: margin, tick: tick, scale: scale, label_offset: label_offset, x_max: x_max, y_max: y_max}
  end
  defp size(params) do
    {width, params} = Map.pop(params, :width, @default_size)
    {height, params} = Map.pop(params, :height, @defualt_size)
    {%{width: width, height: height}, params}
  end
  defp margin(params) do
    {x_margin, params} = Map.pop(params, :x_margin, @default_margin)
    {y_margin, params} = Map.pop(params, :y_margin, @default_margin)
    {%{x_margin: x_margin, y_margin: y_margin}, params}
  end
  defp tick(params) do
    {x_labels, params} = Map.pop(params, :x_labels, [])
    {%{x: x_labels}, params}
  end
  defp label_offset(params) do
    {x_label_offset, params} = Map.pop(params, :x_label_offset, 0)
    {y_label_offset, params} = Map.pop(params, :y_label_offset, 0)
    {%{x: x_label_offset, y: y_label_offset}, params}
  end
  defp scale(params) do
    {x_scale, params}  = Map.pop(params, :x_scale, 0)
    {y_scale, params} = Map.pop(params, :y_scale, 0)
    {%{x: x_scale, y: y_scale}, params}
  end
  defp xymax(%{dataset: [x, y]}) when  is_list(x) and is_list(y) do
    {Enum.max(x), Enum.max(y)}
  end
  defp xymax(_),do: {0,0}
end
