defmodule Matplotex.Figure.Marker do
  @moduledoc false
  alias Matplotex.Utils.Algebra
  alias Matplotex.Element.Rect
  alias Matplotex.Element.Polygon
  alias Matplotex.Element.Circle

  def generate_marker(nil, _, _, _, _), do: nil

  def generate_marker("o", x, y, fill, marker_size),
    # TODO: type shoudl be dynamic plot.marker or scatter.marker

    do: %Circle{type: "plot.marker", cx: x, cy: y, fill: fill, r: marker_size / 96}

  def generate_marker("^", x, y, fill, marker_size),
    do: %Polygon{
      type: "plot.marker",
      points: [{x - marker_size / 96, y}, {x + marker_size / 96, y}, {x, y + marker_size / 96}],
      fill: fill
    }

  def generate_marker("s", x, y, fill, marker_size),
    do: %Rect{
      type: "plot.marker",
      x: x,
      y: y,
      width: marker_size / 96,
      height: marker_size / 96,
      color: fill
    }

  def marker_legend("o", x, y, fill, marker_size) do
    {cx, cy} = Algebra.transform_given_point(x, y, marker_size / 2, marker_size / 2)
    %Circle{type: "legend.handle", cx: cx, cy: cy, fill: fill, r: marker_size / 2}
  end

  def marker_legend("^", x, y, fill, marker_size) do
    %Polygon{
      type: "legend.handle",
      points: [{x, y}, {x + marker_size, y}, {x, y + marker_size}],
      fill: fill
    }
  end

  def marker_legend("s", x, y, fill, marker_size),
    do: %Rect{
      type: "legend.handle",
      x: x,
      y: y,
      width: marker_size,
      height: marker_size,
      color: fill
    }
end
