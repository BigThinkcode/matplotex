defmodule Matplotex.Chart.Area do
  @moduledoc "Area chart — filled path from baseline to data values."
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Scale, Geom}

  @impl true
  def to_geometry(%Dataset{x: x, y: y, color: color}, transform, %Frame{}) do
    n = Nx.size(x)
    order = Nx.argsort(x)
    x_s = Nx.take(x, order)
    y_s = Nx.take(y, order)

    ones = Nx.broadcast(Nx.tensor(1.0, type: :f64), {n})
    zeros = Nx.broadcast(Nx.tensor(0.0, type: :f64), {n})

    tops  = Scale.apply(transform, Nx.stack([x_s, y_s,    ones]))
    bases = Scale.apply(transform, Nx.stack([x_s, zeros,  ones]))

    # Area path: tops left→right, then bases right→left (closed polygon)
    tops_x  = tops[0]  |> Nx.to_list()
    tops_y  = tops[1]  |> Nx.to_list()
    bases_x = bases[0] |> Nx.to_list() |> Enum.reverse()
    bases_y = bases[1] |> Nx.to_list() |> Enum.reverse()

    all_x = Nx.tensor(tops_x ++ bases_x, type: :f64)
    all_y = Nx.tensor(tops_y ++ bases_y, type: :f64)
    coords = Nx.stack([all_x, all_y])

    fill_color = color || "#4e79a7"

    [%Geom.Path{
      coords:       coords,
      closed:       true,
      stroke:       fill_color,
      fill:         fill_color,
      stroke_width: 0,
      opacity:      0.4
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
