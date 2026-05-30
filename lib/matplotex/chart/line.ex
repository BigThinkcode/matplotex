defmodule Matplotex.Chart.Line do
  @moduledoc "Line chart — connects sorted data points with a continuous path."
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Scale, Geom}

  @impl true
  def to_geometry(%Dataset{x: x, y: y, color: color, name: _name}, transform, %Frame{}) do
    # Sort by x for correct line order
    order = Nx.argsort(x)
    x_sorted = Nx.take(x, order)
    y_sorted = Nx.take(y, order)

    n = Nx.size(x_sorted)
    ones = Nx.broadcast(Nx.tensor(1.0, type: :f64), {n})
    points_3xn = Nx.stack([x_sorted, y_sorted, ones])

    # One Nx.dot — all n points transformed at once
    pixel = Scale.apply(transform, points_3xn)

    [%Geom.Path{
      coords:       pixel,
      stroke:       color || "#4e79a7",
      stroke_width: 2,
      fill:         "none"
    }]
  end

  @impl true
  def default_axes do
    [
      {:x1, %Matplotex.Axis{id: :x1, dimension: :x, position: :bottom}},
      {:y1, %Matplotex.Axis{id: :y1, dimension: :y, position: :left}}
    ]
  end
end
