defmodule Matplotex.Chart.Bubble do
  @moduledoc """
  Bubble chart — scatter with z-mapped radii using proper area scaling.

  Area scales linearly with z (not radius), so visual size is proportional
  to value. `dataset.z` = bubble sizes; `min_r` / `max_r` control pixel range.
  """
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Scale, Geom}

  @min_r 4.0
  @max_r 40.0

  @impl true
  def to_geometry(%Dataset{x: x, y: y, z: z, color: color}, transform, %Frame{}) do
    n = Nx.size(x)
    ones = Nx.broadcast(Nx.tensor(1.0, type: :f64), {n})
    pixel = Scale.apply(transform, Nx.stack([x, y, ones]))

    # Area-proportional radius mapping: r = sqrt(z_norm) * max_r
    z_min = z |> Nx.reduce_min() |> Nx.to_number()
    z_max = z |> Nx.reduce_max() |> Nx.to_number()
    span  = max(z_max - z_min, 1.0e-9)

    radii =
      z
      |> Nx.subtract(Nx.tensor(z_min, type: :f64))
      |> Nx.divide(Nx.tensor(span, type: :f64))
      |> Nx.sqrt()
      |> Nx.multiply(Nx.tensor(@max_r - @min_r, type: :f64))
      |> Nx.add(Nx.tensor(@min_r, type: :f64))

    [%Geom.Circles{
      cxcyr:   Nx.stack([pixel[0], pixel[1], radii]),
      fills:   color || "#4e79a7",
      opacity: 0.7
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
