defmodule Matplotex.Figure.Areal.Scatter do
@moduledoc false
  alias Matplotex.Figure.Areal.PlotOptions
  alias Matplotex.Figure.Areal.Region
  alias Matplotex.Figure.Areal.Ticker
  alias Matplotex.Figure.Marker
  alias Matplotex.Figure.Dataset
  alias Matplotex.Element.Legend
  alias Matplotex.Figure.Areal
  alias Matplotex.Figure.RcParams

  alias Matplotex.Figure.Coords
  alias Matplotex.Figure

  use Areal

  frame(
    coords: %Coords{},
    dimension: %Dimension{},
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
  def create(%Figure{axes: %__MODULE__{dataset: data} = axes} = figure, {x, y}, opts \\ []) do
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
    __MODULE__.materialized_by_region(figure)
    |> materialize_elements()
  end

  defp materialize_elements(
         %Figure{
           axes:
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
           rc_params: %RcParams{x_padding: x_padding, y_padding: y_padding}
         } = figure
       ) do
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

  def materialize(xystream, figure) do
    __MODULE__.materialized_by_region(figure)
    |> material_stream(xystream)
  end

  def material_stream(
        %Figure{
          axes: %__MODULE__{
            limit: %TwoD{x: xlim, y: ylim},
            element: element,
            coords: %Coords{bottom_left: {blx, bly}},
            size: {width, height}
          }
        } = figure,
        xystream
      ) do
    {Stream.map(xystream, fn {x, y} ->
       {matx, maty} = transformation(x, y, xlim, ylim, width, height, {blx, bly})
       Marker.generate_marker("o", matx, maty, "blue", 5)
     end)
     |> Stream.concat(element), figure}
  end

  defp capture(%Dataset{transformed: transformed} = dataset) do
    capture(transformed, [], dataset)
  end

  defp capture(
         [{x, y} | to_capture],
         captured,
         %Dataset{
           color: color,
           marker: marker,
           marker_size: marker_size
         } = dataset
       ) do
    capture(
      to_capture,
      captured ++
        [
          Marker.generate_marker(marker, x, y, color, marker_size)
        ],
      dataset
    )
  end

  defp capture(_, captured, _), do: captured

  @impl Areal
  def with_legend_handle(
        %Legend{x: x, y: y, color: color, width: marker_size} = legend,
        %Dataset{marker: marker}
      ) do
    %Legend{legend | handle: Marker.marker_legend(marker, x, y, color, marker_size)}
  end

  def generate_ticks([{_l, _v} | _] = data) do
    {data, min_max(data)}
  end

  def generate_ticks(data) when is_list(data) do
    lim = Enum.min_max(data)

    {Ticker.generate_ticks(lim), lim}
  end

  def generate_ticks({_min, _max} = lim) do
    {Ticker.generate_ticks(lim), lim}
  end
end
