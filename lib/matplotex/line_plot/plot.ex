defmodule Matplotex.LinePlot.Plot do
  alias Matplotex.BarChart.Element
  use Matplotex.Blueprint
  alias Matplotex.LinePlot
  alias Matplotex.LinePlot.Content
  @defualt_size 400
  @default_margin 15

  @content_fields [:label_offset, :x_max, :y_max]

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
    %LinePlot{plotset | content: %Content{content | width: width - y_label_offset - 2 * x_margin, height: height - x_label_offset - 2 * y_margin}}
  end
  def add_elements(plotset) do
    plotset
    |>add_axis_lines()
    |>add_grid_lines()

  end

  def generate_svg(graphset) do

  end


  defp add_axis_lines(plotset) do
   axis_lines =  Matplotex.Element.AxisLine.genarate_axis_lines() |>Enum.filter(& &!is_nil/1)
   element = %Element{axis: axis_lines}
   %{plotset | element: element}
  end
  defp add_grid_lines(%LinePlot{dataset: [x_data, y_data]} = plotset) do
    {x_min, x_max} = x_data|>List.flatten()|>Enum.min_max()
    {y_min, y_max} = y_data|>List.flatten()|>Enum.min_max()



  end

  defp generate_chart_params(%{"dataset"=> _dataset}= params) do
    params = for {k, v} <- params, into: %{}, do: {String.to_atom(k), v}
    generate_chart_params(params)
  end

  defp generate_chart_params(params) do
    {size, params} = size(params)
    {margin, params} = margin(params)
    {label, params} = label(params)
    {label_offset, params} = label_offset(params)
    {scale, params} = scale(params)
    {x_max, y_max} = xymax(params)
    %{params | size: size, margin: margin, label: label, scale: scale, label_offset: label_offset, x_max: x_max, y_max: y_max}
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
  defp label(params) do
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
