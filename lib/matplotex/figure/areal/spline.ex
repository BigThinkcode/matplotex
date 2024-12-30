defmodule Matplotex.Figure.Areal.Spline do
  alias Matplotex.Figure.Areal
  alias Matplotex.Figure.Dataset
  alias Matplotex.Figure.Areal.PlotOptions
  alias Matplotex.Figure.Areal.Region
  alias Matplotex.Figure.TwoD
  alias Matplotex.Figure


  use Areal

  frame(
    tick: %TwoD{},
    limit: %TwoD{},
    label: %TwoD{},
    region_x: %Region{},
    region_y: %Region{},
    region_title: %Region{},
    region_legend: %Region{},
    region_content: %Region{}
  )
  @impl Areal
  def create(
        %Figure{axes: %__MODULE__{dataset: data} = axes} = figure,
        {x, y},
        opts
      ) do
    x = determine_numeric_value(x)
    y = determine_numeric_value(y)
    dataset = Dataset.cast(%Dataset{x: x, y: y}, opts)
    datasets = data ++ [dataset]
    xydata = flatten_for_data(datasets)

    %Figure{figure | axes: %{axes | data: xydata, dataset: datasets}}
    |> PlotOptions.set_options_in_figure(opts)
  end

  @impl Areal
  def materialize(figure) do
   figure
   |>__MODULE__.materialized_by_region()
   |> materialize_spline()

  end
  defp materialize_spline(%Figure{axes:
  %{
    dataset: data,
    limit: %{x: xlim, y: ylim},
    region_content: %Region{
      x: x_region_content,
      y: y_region_content,
      width: width_region_content,
      height: height_region_content
    },
    element: elements
  } = axes,
   rc_params: %RcParams{x_padding: x_padding, y_padding: y_padding}}) do
    x_padding_value = width_region_content * x_padding
    y_padding_value = height_region_content * y_padding
    shrinked_width_region_content = width_region_content - x_padding_value * 2
    shrinked_height_region_content = height_region_content - y_padding_value * 2

    line_elements =
      data
      |> Enum.map(fn dataset ->
        dataset
        |> do_transform(
          xlim,
          ylim,
          shrinked_width_region_content,
          shrinked_height_region_content,
          {x_region_content + x_padding_value, y_region_content + y_padding_value}
        )
        |> capture()
      end)
      |> List.flatten()

    elements = elements ++ line_elements

    %Figure{figure | axes: %{axes | element: elements}}
  end


  defp capture(%Dataset{transformed: transformed} = dataset) do
    capture(transformed, [], dataset)
  end


  defp capture(%Dataset{transformed: transformed} = dataset, bly, region_width) do
    capture(transformed, [], dataset, bly, region_width)
  end

  defp capture(
         [{x, y} | to_capture],
         captured,
         %Dataset{
           color: color,
           x: bins,
           pos: pos_factor,
           edge_color: edge_color,
           alpha: alpha
         } = dataset,
         bly,
         region_width
       ) do
    capture(
      to_capture,
      captured ++
        [
          %Rect{
            type: "figure.histogram",
            x: bin_position(x, pos_factor),
            y: y,
            width: region_width / length(bins),
            height: bly - y,
            color: color,
            stroke: edge_color,
            fill_opacity: alpha,
            stroke_opacity: alpha
          }
        ],
      dataset,
      bly,
      region_width
    )
  end

  defp capture([], captured, _dataset, _bly, _region_width), do: captured

end
