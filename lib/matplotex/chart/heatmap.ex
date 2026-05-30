defmodule Matplotex.Chart.Heatmap do
  @moduledoc """
  Heatmap — grid of colored cells.

  Data format: `dataset.x` = column index, `dataset.y` = row index,
  `dataset.z` = intensity value.

  Colors are mapped through `Stat.colorscale/2`.
  """
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Scale, Stat, Geom}

  @impl true
  def to_geometry(%Dataset{x: x, y: y, z: z}, transform, %Frame{}) do
    n = Nx.size(x)
    ones = Nx.broadcast(Nx.tensor(1.0, type: :f64), {n})

    # Transform cell centers
    pixel = Scale.apply(transform, Nx.stack([x, y, ones]))

    # Cell size from adjacent pixel positions (assume regular grid)
    xs = Nx.to_list(pixel[0])
    ys = Nx.to_list(pixel[1])
    zs = Nx.to_list(z)

    unique_xs = xs |> Enum.uniq() |> Enum.sort()
    unique_ys = ys |> Enum.uniq() |> Enum.sort()

    cw = if length(unique_xs) > 1, do: abs(Enum.at(unique_xs, 1) - hd(unique_xs)), else: 20.0
    ch = if length(unique_ys) > 1, do: abs(Enum.at(unique_ys, 1) - hd(unique_ys)), else: 20.0

    z_min = Enum.min(zs)
    z_max = Enum.max(zs)
    z_span = max(z_max - z_min, 1.0e-9)

    {xywh_rows, fills} =
      Enum.zip([xs, ys, zs])
      |> Enum.map(fn {px, py, pz} ->
        t = (pz - z_min) / z_span
        color = Stat.colorscale(t, :viridis)
        {[px - cw / 2, py - ch / 2, cw, ch], color}
      end)
      |> Enum.unzip()

    xywh_tensor = xywh_rows |> Nx.tensor(type: :f64) |> Nx.transpose()

    [%Geom.Rects{xywh: xywh_tensor, fills: fills}]
  end

  @impl true
  def default_axes do
    [
      {:x1, %Matplotex.Axis{id: :x1, dimension: :x, position: :bottom}},
      {:y1, %Matplotex.Axis{id: :y1, dimension: :y, position: :left}}
    ]
  end
end
