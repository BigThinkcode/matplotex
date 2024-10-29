defmodule Matplotex.Figure.Areal.Scatter do

  alias Matplotex.Element.Circle
  alias Matplotex.Figure.Areal
  alias Matplotex.Figure.RcParams

  alias Matplotex.Figure.Coords
  alias Matplotex.Figure

  use Areal
  @r 5
  @impl Areal
  def create(x, y) do
    x = determine_numeric_value(x)
    y = determine_numeric_value(y)
    %Figure{axes: struct(__MODULE__, %{data: {x, y}})}
  end

  @impl Areal
  def materialize(figure) do
    __MODULE__.materialized(figure)
    |> materialize_elements()
  end
  defp materialize_elements(
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

scatter_elements =
 x
 |> Enum.zip(y)
 |> Enum.map(fn {x, y} ->
   transformation(x, y, xlim, ylim, width, height, {blx + px, bly + py})
 end)
 |> capture([])

elements = elements ++ scatter_elements
%Figure{figure | axes: %{axes | element: elements}}
end


defp capture([{cx, cy} | to_capture], captured) do
  capture(to_capture, captured ++ [%Circle{type: "scatter.marker", cx: cx, cy: cy, r: @r}])
end

defp capture(_, captured), do: captured
@impl Areal
def plotify(value, {minl, maxl}, axis_size, transition, _, _) do
    s = axis_size / (maxl - minl)
    value * s + transition - minl * s
  end

end
