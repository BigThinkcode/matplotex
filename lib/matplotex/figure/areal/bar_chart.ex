defmodule Matplotex.Figure.Areal.BarChart do
  import Matplotex.Figure.Numer
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
    label: %TwoD{}
  )

  @impl Areal
  def create(
        %Figure{axes: %__MODULE__{dataset: data} = axes} = figure,
        {pos, values, width},
        opts
      ) do
    x = hypox(values)
    dataset = Dataset.cast(%Dataset{x: x, y: values, pos: pos, width: width}, opts)
    datasets = data ++ [dataset]
    xydata = flatten_for_data(datasets)
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
    width = width - px * 2
    py = height * padding
    height = height - py * 2

    bar_elements =
      data
      |> Enum.map(fn dataset ->
        dataset
        |> do_transform(xlim, ylim, width, height, {blx + px, bly + py})
        |> capture(bly)
      end)
      |> List.flatten()

    elements_with_bar = elements ++ bar_elements

    %Figure{figure | axes: %{axes | element: elements_with_bar}}
  end

  @impl Areal
  def plotify(value, {minl, maxl}, axis_size, transition, _data, :x) do
    s = axis_size / (maxl - minl)
    value * s + transition - minl * s
  end

  def plotify(value, {minl, maxl}, axis_size, transition, _data, :y) do
    s = axis_size / (maxl - minl)
    value * s + transition - minl * s
  end

  def generate_ticks([{_l, _v} | _] = data) do
    {data, min_max(data)}
  end

  def generate_ticks(data) do
    max = Enum.max(data)
    step = max |> round_to_best() |> div(5) |> round_to_best()
    {list_of_ticks(data, step), {0, max}}
  end

  def generate_ticks(side, {min, max} = lim) do
    step = (max - min) / (side * 2)
    {min..max |> Enum.into([], fn d -> d * round_to_best(step) end), lim}
  end

  defp capture(%Dataset{transformed: transformed} = dataset, bly) do
    capture(transformed, [], dataset, bly)
  end

  defp capture(
         [{x, y} | to_capture],
         captured,
         %Dataset{
           color: color,
           width: width,
           pos: pos_factor
         } = dataset,
         bly
       ) do
    capture(
      to_capture,
      captured ++
        [
          %Rect{
            type: "figure.bar",
            x: bar_position(x, pos_factor),
            y: y,
            width: width,
            height: y - bly,
            color: color
          }
        ],
      dataset,
      bly
    )
  end

  defp capture([], captured, _dataset, _bly), do: captured

  defp hypox(y) do
    1..length(y) |> Enum.into([])
  end

  defp bar_position(x, pos_factor) when pos_factor < 0 do
    x + pos_factor
  end

  defp bar_position(x, _pos_factor), do: x

  defp list_of_ticks(data, step) do
    1..length(data)
    |> Enum.into([], fn d ->
      d * step
    end)
  end
end
