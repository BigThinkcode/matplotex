defmodule Matplotex.LinePlot do
  alias Matplotex.Element.Circle
  alias Matplotex.LinePlot
  alias Matplotex.Figure.Dataset
  alias Matplotex.Figure.Areal
  alias Matplotex.Figure.RcParams
  alias Matplotex.Element.Line
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure

  use Matplotex.Figure.Areal

  frame(
    legend: %Legend{},
    coords: %Coords{},
    dimension: %Dimension{},
    tick: %TwoD{},
    limit: %TwoD{},
    title: %Text{}
  )

  @marker_size 5

  @impl Areal
  def create(%Figure{axes: %LinePlot{dataset: data} = axes} = figure, x, y, opts \\ []) do
    x = determine_numeric_value(x)
    y = determine_numeric_value(y)
    opts = Enum.into(opts, %{})
    dataset = Map.merge(%Dataset{x: x, y: y}, opts)
    datasets = data ++ [dataset]
    %Figure{figure | axes: %{axes | data: flatten_for_data(datasets), dataset: datasets}}
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
      |>List.flatten()

    elements = elements ++ line_elements
    %Figure{figure | axes: %{axes | element: elements}}
  end

  @impl Areal
  def plotify(value, {minl, maxl}, axis_size, transition, _, _) do
    s = axis_size / (maxl - minl)
    value * s + transition - minl * s
  end

  defp do_transform(%Dataset{x: x, y: y} = dataset, xlim, ylim, width, height, transition) do
    transformed =
      x
      |> Enum.zip(y)
      |> Enum.map(fn {x, y} ->
        transformation(x, y, xlim, ylim, width, height, transition)
      end)

    %Dataset{dataset | transformed: transformed}
  end

  defp capture(%Dataset{transformed: transformed} = dataset) do
    capture(transformed, [], dataset)
  end

  defp capture([{x1, y1} | [{x2, y2} | _] = to_capture], captured, %Dataset{
         color: color,
         marker: marker,
         linestyle: linestyle
  } = dataset) do
    capture(
      to_capture,
      captured ++
        [
          %Line{type: "plot.line", x1: x1, y1: y1, x2: x2, y2: y2, fill: color, linestyle: linestyle},
            generate_marker(marker, x1, y1, color)
        ], dataset
    )
  end

  defp capture([{x, y}], captured, %Dataset{color: color, marker: marker}) do
    captured ++ [generate_marker(marker, x, y, color)]
  end


  defp flatten_for_data(datasets) do
    datasets
    |> Enum.map(fn %{x: x, y: y} -> {x, y} end)
    |> Enum.unzip()
    |> then(fn {xs, ys} ->
      {xs |> List.flatten() |> MapSet.new() |> MapSet.to_list(),
       ys |> List.flatten() |> MapSet.new() |> MapSet.to_list()}
    end)
  end

  defp generate_marker(nil, _, _, _), do: nil
  defp generate_marker("o", x, y, fill), do: %Circle{type: "plot.marker", cx: x, cy: y, fill: fill, r: @marker_size}
end
