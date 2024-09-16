defmodule Matplotex.LinePlot.Plot do
  alias Matplotex.LinePlot.Element
  use Matplotex.Blueprint
  alias Matplotex.LinePlot
  alias Matplotex.LinePlot.Content
  alias Matplotex.Element.AxisLine
  alias Matplotex.Element.GridLine
  alias Matplotex.Element.Line
  @default_size 400
  @default_margin 15
  @label_offset 20
  @scale 10
  @tick_length 5

  @content_fields [:label_offset, :x_max, :y_max, :line_width, :color_palette]

  @spec new(atom() | struct(), map()) :: {struct(), any()}
  def new(graph, params) do
    {params, content_params} =
      params
      |> validate_params()
      |> generate_chart_params()
      |> segregate_content(@content_fields)

    {struct(graph, params), content_params}
  end

  def set_content(
        {%LinePlot{
           size: %{width: width, height: height},
           margin: %{x_margin: x_margin, y_margin: y_margin}
         } = plotset, %{label_offset: %{x: x_label_offset, y: y_label_offset}} = content_params}
      ) do
    content = struct(Content, content_params)

    %LinePlot{
      plotset
      | content: %Content{
          content
          | width: width - y_label_offset - 2 * x_margin,
            height: height - x_label_offset - 2 * y_margin,
            x: x_margin + y_label_offset,
            y: y_margin + y_label_offset
        }
    }
  end
  def set_content(plotset) do
    errors = Map.get(plotset, :errors, [])
    %LinePlot{plotset | valid: false, element: errors ++ ["Not valid to set content"]}

  end

  def add_elements(plotset) do
    plotset
    |> add_axis_lines()
    |> add_grid_lines()
    |> add_plot_lines()
    |> add_labels()
    |> add_ticks()
  end

  def generate_svg(%{valid: false, errors: errors}) do
    "Invalid line plot #{inspect(errors)}"
  end

  defp add_labels(%LinePlot{element: element, margin: %{x_margin: x_margin,y_margin: y_margin}, label: label, content: %Content{height: content_height, width: content_width }} = plotset) do
    x_label = Map.get(label, :x)
    y_label = Map.get(label, :y)
   labels = [%Label{type: "label.xaxis", x: content_width/2, y: y_margin, text: x_label},
    %Label{type: "label.yaxis", x: x_margin, y: content_height/2, text: y_label}]
   element = %Element{element | labels: labels}
   %LinePlot{plotset | element: element}

  end
  defp add_labels(%LinePlot{errors: errors} = plotset) do
    %LinePlot{plotset | valid: false, errors: errors ++ ["Not a valid line plot to add labels required fields are:   #{inspect([ margin: plotset.margin, content: plotset.content ])} "]}
  end
  defp add_ticks(%LinePlot{grid_coordinates: %{x: x_grid_coords, y: y_grid_coords}, element: element, content: %Content{x: content_x, y: content_y}, tick: %{x: x_ticks,y: y_ticks}} = plotset) do
  x_ticks =   x_ticks|>Enum.zip(x_grid_coords)|>Enum.map(fn {label, {x, y}} ->
      %Tick{
        #TODO: Make tick length  also from input
        label: %Label{x: x, y: y+@tick_length, text: label},
        tick_line: %Line{x1: x, y1: y, x2: x, y2: y+@tick_length}

      }
     end)
    y_ticks = y_ticks|>Enum.zip(y_grid_coords)|>Enum.map(fn {label, {x, y}} ->
    %Tick{
      label: %Label{x: x - @tick_length, y: y, text: label},
      tick_line: %Line{x1: x, y1: y, x2: x + @tick_length, y2: y}
    }
    end)

    element = %Element{element | ticks: x_ticks ++ y_ticks}
    %LinePlot{plotset | element: element}
  end

  defp add_ticks(%LinePlot{show_ticks: false} = plotset), do: plotset

  defp add_ticks(plotset) do
    errors = fetch_errors(plotset)
    %LinePlot{plotset | valid: false, errors: errors ++ ["Not valid to add ticks"]}
  end

  defp add_plot_lines(
         %LinePlot{
           dataset: dataset,
           element: element,
           content: %Content{color_palette: color_palette}
         } = plotset
       ) do
    plot_lines =
      dataset
      |> Enum.zip(color_palette)
      |> Enum.map(&generate_plot_lines(&1, plotset))
      |>List.flatten()

    element = %Element{element | lines: plot_lines}
    %LinePlot{plotset | element: element}
  end

  defp add_plot_lines(plotset) do
    errors = fetch_errors(plotset)
    %LinePlot{plotset | valid: false, errors: errors ++ ["Not valid to add plot lines"]}
  end

  defp generate_plot_lines({dataset, color}, %LinePlot{
         content: %Content{
           x: content_x,
           y: content_y,
           width: content_width,
           line_width: line_width,
           height: content_height
         }
       }) do

    [x_minmax, y_minmax] =
      dataset
      |> Enum.with_index()
      |> Enum.unzip()
      |> Tuple.to_list()
      |> Enum.map(&Enum.min_max/1)

    {contentx_tr, contenty_tr} =
      transformation(content_x, content_y, x_minmax, y_minmax, content_width, content_height)
      |> transform_to_svg(content_height)

    dataset
    |> Enum.with_index()
    |> Enum.reduce({[], %{x1: contentx_tr, y1: contenty_tr}}, fn {x, y},
                                                                 {lines, %{x1: x1, y1: y1}} ->
      {x2_tr, y2_tr} =
        transformation(x, y, x_minmax, y_minmax, content_width, content_height)
        |> transform_to_svg(content_height)

      {lines ++
         [%Line{x1: x1, x2: x2_tr, y1: y1, y2: y2_tr, stroke: color, stroke_width: line_width}],
       %{x1: x2_tr, y1: y2_tr}}
    end)
    |> then(fn {lines, _} -> lines end)
  end
  defp generate_plot_lines(_,_),do: []
  defp add_axis_lines(plotset) do
    axis_lines = plotset |> AxisLine.genarate_axis_lines() |> Enum.filter(fn x -> !is_nil(x) end)
    element = %Element{axis: axis_lines}
    %{plotset | element: element}
  end

  defp add_grid_lines(
         %LinePlot{dataset: dataset, tick: %{x: x_labels}, type: "line_chart"} = plotset
       ) do
    x_minmax = 0..length(x_labels) |> Enum.min_max()
    y_minmax = dataset |> List.flatten() |> Enum.min_max()

    GridLine.generate_grid_lines(plotset, x_minmax, y_minmax)
  end

  defp add_grid_lines(plotset), do: plotset

  defp generate_chart_params({:ok, %{"dataset" => _dataset} = params}) do
    params = for {k, v} <- params, into: %{}, do: {String.to_atom(k), v}

    generate_chart_params(params)
  end
  defp generate_chart_params({:ok, params}), do: generate_chart_params(params)

  defp generate_chart_params(params) do
    {size, params} = size(params)
    {margin, params} = margin(params)
    {tick, params} = tick(params)
    {label_offset, params} = label_offset(params)
    {scale, params} = scale(params)
    {label, params} = label(params)
    {x_max, y_max} = xymax(params)


    Map.merge(params, %{
      size: size,
      margin: margin,
      tick: tick,
      scale: scale,
      label_offset: label_offset,
      x_max: x_max,
      y_max: y_max,
      label: label
    })
  end

  defp size(params) do
    {width, params} = Map.pop(params, :width, @default_size)
    {height, params} = Map.pop(params, :height, @default_size)
    {%{width: width, height: height}, params}
  end

  defp margin(params) do
    {x_margin, params} = Map.pop(params, :x_margin, @default_margin)
    {y_margin, params} = Map.pop(params, :y_margin, @default_margin)
    {%{x_margin: x_margin, y_margin: y_margin}, params}
  end

  defp tick(params) do
    {x_labels, params} = Map.pop(params, :x_labels, [])
    {y_labels, params} = Map.pop(params, :y_labels, [])
    #TODO: A way to identify weather the graph requires y ticks or not
    {%{x: x_labels, y: y_labels}, params}
  end

  defp label_offset(params) do
    {x_label_offset, params} = Map.pop(params, :x_label_offset, @label_offset)
    {y_label_offset, params} = Map.pop(params, :y_label_offset, @label_offset)
    {%{x: x_label_offset, y: y_label_offset}, params}
  end

  defp scale(params) do
    {x_scale, params} = Map.pop(params, :x_scale, @scale)
    {y_scale, params} = Map.pop(params, :y_scale, @scale)
    {%{x: x_scale, y: y_scale}, params}
  end

  defp label(params) do
    {x_label, params} = Map.pop(params, :x_label)
    {y_label, params} = Map.pop(params, :y_label)
    {%{x: x_label, y: y_label}, params}
  end

  defp xymax(%{dataset: [x, y]}) when is_list(x) and is_list(y) do
    {Enum.max(x), Enum.max(y)}
  end

  defp xymax(_), do: {0, 0}
end
