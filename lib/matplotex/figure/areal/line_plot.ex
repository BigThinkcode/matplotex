defmodule Matplotex.Figure.Areal.LinePlot do
  alias Matplotex.Figure.Marker
  alias Matplotex.Figure.Dataset
  alias Matplotex.Figure.Areal
  alias Matplotex.Figure.RcParams
  alias Matplotex.Element.Line
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure
  import Matplotex.Figure.Numer

  use Matplotex.Figure.Areal

  frame(
    legend: %Legend{},
    coords: %Coords{},
    dimension: %Dimension{},
    tick: %TwoD{},
    limit: %TwoD{},
    label: %TwoD{}
  )

  @marker_size 3.5
  @impl Areal
  def create(%Figure{axes: %__MODULE__{dataset: data} = axes} = figure, {x, y}, opts \\ []) do
    x = determine_numeric_value(x)
    y = determine_numeric_value(y)
    dataset = Dataset.cast(%Dataset{x: x, y: y}, opts)
    datasets = data ++ [dataset]
    xydata = flatten_for_data(datasets)
    %Figure{figure | axes: %{axes | data: xydata, dataset: datasets}}
  end

  @impl Areal
  def materialize(figure) do
    figure
    |> __MODULE__.materialized()
    |> materialize_lines()
  end

  defp materialize_lines(
         %Figure{
           axes:
             %{
               dataset: data,
               limit: %{x: xlim, y: ylim},
               size: {width, height},
               coords: %Coords{bottom_left: {blx, bly}},
               element: elements
             } = axes,
           rc_params: %RcParams{x_padding: x_padding, y_padding: y_padding}
         } = figure
       ) do
    px = width * x_padding
    py = height * y_padding
    width = width - px * 2
    height = height - py * 2

    line_elements =
      data
      |> Enum.map(fn dataset ->
        dataset
        |> do_transform(xlim, ylim, width, height, {blx + px, bly + py})
        |> capture()
      end)
      |> List.flatten()

    elements = elements ++ line_elements
    %Figure{figure | axes: %{axes | element: elements}}
  end

  @impl Areal
  def plotify(value, {minl, maxl}, axis_size, transition, _, _) do
    s = axis_size / (maxl - minl)
    value * s + transition - minl * s
  end

  def generate_ticks([{_l, _v} | _] = data) do
    {data, min_max(data)}
  end

  def generate_ticks(data) do
    {min, max} = lim = Enum.min_max(data)
    step = (max - min) / (length(data) - 1)
    {min..max |> Enum.into([], fn d -> d * round(step) end), lim}
  end

  def generate_ticks(side, {min, max} = lim) do
    step = (max - min) / (side * 2)
    {min..max |> Enum.into([], fn d -> d * round_to_best(step) end), lim}
  end

  defp capture(%Dataset{transformed: transformed} = dataset) do
    capture(transformed, [], dataset)
  end

  defp capture(
         [{x1, y1} | [{x2, y2} | _] = to_capture],
         captured,
         %Dataset{
           color: color,
           marker: marker,
           linestyle: linestyle
         } = dataset
       ) do
    capture(
      to_capture,
      captured ++
        [
          %Line{
            type: "plot.line",
            x1: x1,
            y1: y1,
            x2: x2,
            y2: y2,
            stroke: color,
            fill: color,
            linestyle: linestyle
          },
          Marker.generate_marker(marker, x1, y1, color, @marker_size)
        ],
      dataset
    )
  end

  defp capture([{x, y}], captured, %Dataset{color: color, marker: marker}) do
    captured ++ [Marker.generate_marker(marker, x, y, color, @marker_size)]
  end
end
