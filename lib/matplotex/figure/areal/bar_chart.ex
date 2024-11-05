defmodule Matplotex.Figure.Areal.BarChart do
  alias Matplotex.Figure.Dataset
  alias Matplotex.Element.Rect
  alias Matplotex.Figure.RcParams
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure
  alias Matplotex.Figure.Areal
  use Areal

  frame(
    legend: %Legend{},
    coords: %Coords{},
    dimension: %Dimension{},
    tick: %TwoD{},
    limit: %TwoD{},
    title: %Text{}
  )
  @impl Areal
  def create(%Figure{axes: %__MODULE__{dataset: data} = axes} = figure, {pos, values, width},opts) do

    x = hypox(values)
    dataset = Dataset.cast(%Dataset{x: x, y: values, pos: pos, width: width}, opts)
    datasets = data ++ [dataset]
    xydata= flatten_for_data(datasets)
    %Figure{figure | axes: %{axes | data: xydata, dataset: datasets}}
  end

  @impl Areal
  def materialize(figure) do
    __MODULE__.materialized(figure)
    |> materialize_bars()
  end

  defp materialize_bars(
         %Figure{
           axes:
             %{
               dataset: data,
               limit: %{x: xlim, y: ylim},
               size: {width, height},
               coords: %Coords{bottom_left: {blx, bly}},
               element: elements
             } = axes,
           rc_params: %RcParams{x_padding: padding}
         } = figure
       ) do

    px = width * padding
    width = width - px
    py = height * padding
    height = height - py

    bar_elements =
      data
      |>Enum.map(fn dataset ->
        dataset
        |>do_transform(xlim, ylim, width, height, {blx + px, bly + py})
        |>capture(bly)
      end)
      |>List.flatten()

    elements_with_bar = elements ++ bar_elements

    %Figure{figure | axes: %{axes | element: elements_with_bar}}
  end

  @impl Areal
  def plotify(value, {minl, maxl}, axis_size, transition, data, :x) do
    offset = axis_size / length(data) / 2
    s = (axis_size - offset) / (maxl - minl)
    value * s + transition - minl * s + offset
  end

  def plotify(value, {minl, maxl}, axis_size, transition, _data, :y) do
    s = axis_size / (maxl - minl)
    value * s + transition - minl * s
  end


  defp capture(%Dataset{transformed: transformed} = dataset, bly) do
    capture(transformed, [], dataset, bly)
  end

  defp capture([{x, y} | to_capture], captured, %Dataset{
         color: color,
         width: width,
         pos: pos_factor
  } = dataset, bly) do
    capture(
      to_capture,
      captured ++
        [%Rect{type: "figure.bar", x: x + pos_factor, y: y, width: width, height: y-bly, color: color}], dataset, bly
    )
  end

  defp capture([], captured, _dataset, _bly), do: captured
  defp hypox(y) do
    1..length(y) |> Enum.into([])
  end

end
