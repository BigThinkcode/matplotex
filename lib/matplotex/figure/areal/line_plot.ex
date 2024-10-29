defmodule Matplotex.LinePlot do
  alias Matplotex.Figure.Areal
  alias Matplotex.Figure.RcParams
  alias Matplotex.Element.Line
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure

  use Matplotex.Figure.Areal
  @impl Areal
  def create(x, y) do
    x = determine_numeric_value(x)
    y = determine_numeric_value(y)
    %Figure{axes: struct(__MODULE__, %{data: {x, y}})}
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
               data: {x, y},
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
      x
      |> Enum.zip(y)
      |> Enum.map(fn {x, y} ->
        transformation(x, y, xlim, ylim, width, height, {blx + px, bly + py})
      end)
      |> capture([])

    elements = elements ++ line_elements
    %Figure{figure | axes: %{axes | element: elements}}
  end

  @impl Areal
  def plotify(value, {minl, maxl}, axis_size, transition, _, _) do
    s = axis_size / (maxl - minl)
    value * s + transition - minl * s
  end

  defp capture([{x1, y1} | [{x2, y2} | _] = to_capture], captured) do
    capture(to_capture, captured ++ [%Line{type: "plot.line", x1: x1, y1: y1, x2: x2, y2: y2}])
  end

  defp capture(_, captured), do: captured
end
