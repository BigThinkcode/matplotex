defmodule Matplotex.Chart.Spline do
  @moduledoc """
  Spline chart — smooth Catmull-Rom curves through data points.

  Converts Catmull-Rom control points to SVG cubic Bezier curves.
  Each segment uses four points (prev, p0, p1, next) to compute
  the two Bezier control points.
  """
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Scale, Geom}

  @tension 0.5

  @impl true
  def to_geometry(%Dataset{x: x, y: y, color: color}, transform, %Frame{}) do
    order = Nx.argsort(x)
    x_s = Nx.take(x, order) |> Nx.to_list()
    y_s = Nx.take(y, order) |> Nx.to_list()
    n   = length(x_s)

    ones  = Nx.broadcast(Nx.tensor(1.0, type: :f64), {n})
    pts_3 = Nx.stack([Nx.tensor(x_s, type: :f64), Nx.tensor(y_s, type: :f64), ones])
    pixel = Scale.apply(transform, pts_3)

    px_list = pixel[0] |> Nx.to_list()
    py_list = pixel[1] |> Nx.to_list()

    # Pad endpoints: duplicate first and last for Catmull-Rom
    pxs = [hd(px_list)] ++ px_list ++ [List.last(px_list)]
    pys = [hd(py_list)] ++ py_list ++ [List.last(py_list)]

    # Build cubic bezier path string: M + S segments
    {path_d, _} =
      Enum.zip(pxs, pys)
      |> Enum.chunk_every(4, 1, :discard)
      |> Enum.reduce({"", true}, fn [{x0, y0}, {x1, y1}, {x2, y2}, {x3, y3}], {d, first} ->
        # Catmull-Rom → Bezier control points
        cp1x = x1 + (x2 - x0) * @tension / 3.0
        cp1y = y1 + (y2 - y0) * @tension / 3.0
        cp2x = x2 - (x3 - x1) * @tension / 3.0
        cp2y = y2 - (y3 - y1) * @tension / 3.0

        start = if first, do: "M #{x1} #{y1} ", else: ""
        seg   = "C #{cp1x} #{cp1y} #{cp2x} #{cp2y} #{x2} #{y2} "

        {d <> start <> seg, false}
      end)

    # Spline uses an SVG path string directly (exception: geometry encodes via attrs)
    [%Geom.Path{
      coords:       nil,
      stroke:       color || "#4e79a7",
      stroke_width: 2,
      fill:         "none",
      # Store the pre-built SVG path string in a side-channel for the renderer
      stroke_dasharray: nil
    }
    |> Map.put(:svg_path_d, String.trim(path_d))]
  end

  @impl true
  def default_axes do
    [
      {:x1, %Matplotex.Axis{id: :x1, dimension: :x, position: :bottom}},
      {:y1, %Matplotex.Axis{id: :y1, dimension: :y, position: :left}}
    ]
  end
end
