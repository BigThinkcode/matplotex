defmodule Matplotex.Figure.Areal.BarChart do
  alias Matplotex.Element.Rect
  alias Matplotex.Figure.RcParams

  alias Matplotex.Figure.Coords
  alias Matplotex.Figure

  @upadding 0.05

  alias Matplotex.Figure.Areal
  use Areal
  @impl Areal
  def create(x, y) do
    x = determine_numeric_value(x)
    y = determine_numeric_value(y)
    %Figure{axes: struct(__MODULE__, %{data: {x, y}})}
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
               data: {x, y},
               limit: %{x: xlim, y: ylim},
               size: {width, height},
               coords: %Coords{bottom_left: {blx, bly}},
               element: elements
             } = axes,
           rc_params: %RcParams{x_padding: padding}
         } = figure
       ) do

    offset = width/length(x) / 2
    px = width * padding
    width = width - px * 2 - offset

    IO.inspect(x)
    IO.inspect(y)

    unit_space = width / length(x)
    bar_width = unit_space - unit_space * @upadding

    bar_elements =
      x
      |> Enum.zip(y)
      |> tap(fn x -> IO.inspect(x) end)
      |> Enum.map(fn {x, y} ->
        transformation(x, y, xlim, ylim, width, height, {blx + px, bly})
      end)
      |> capture(bar_width, bly, [])

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

  defp capture([{x, y} | to_capture], bar_width, bly, captured) do
    bar =
      %Rect{type: "figure.bar", x: x, y: y, width: bar_width, height: y - bly}

    # IO.inspect({x * 96, y * 96})
    capture(
      to_capture,
      bar_width,
      bly,
      captured ++ [bar]
    )
  end

  defp capture(_, _, _, captured), do: captured
end
