defmodule Matplotex.Chart.Scatter do
  @moduledoc """
  Scatter chart — one circle per data point.

  If `dataset.z` is set, z values are mapped to circle radius (bubble chart
  fallback — use `Chart.Bubble` for proper bubble scaling).
  """
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Scale, Geom}

  @default_radius 5.0

  @impl true
  def to_geometry(%Dataset{x: x, y: y, z: z, color: color}, transform, %Frame{}) do
    n = Nx.size(x)
    ones = Nx.broadcast(Nx.tensor(1.0, type: :f64), {n})
    pixel = Scale.apply(transform, Nx.stack([x, y, ones]))

    radii =
      if z do
        z_min = z |> Nx.reduce_min() |> Nx.to_number()
        z_max = z |> Nx.reduce_max() |> Nx.to_number()
        span = max(z_max - z_min, 1.0e-9)
        Nx.multiply(
          Nx.divide(Nx.subtract(z, Nx.tensor(z_min, type: :f64)), Nx.tensor(span, type: :f64)),
          Nx.tensor(15.0, type: :f64)
        )
        |> Nx.add(Nx.tensor(3.0, type: :f64))
      else
        Nx.broadcast(Nx.tensor(@default_radius, type: :f64), {n})
      end

    cxcyr = Nx.stack([pixel[0], pixel[1], radii])

    [%Geom.Circles{
      cxcyr: cxcyr,
      fills: color || "#4e79a7"
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
