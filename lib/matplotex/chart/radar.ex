defmodule Matplotex.Chart.Radar do
  @moduledoc """
  Radar / spider chart — n-dimensional data plotted on radial axes.

  Data format: `dataset.y` = values (one per axis); `dataset.labels` = axis names.
  All axes share [0, 1] normalized range; raw values normalized per axis.
  Multiple datasets → multiple overlapping polygons.
  """
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Geom}

  @impl true
  def to_geometry(%Dataset{y: y, color: color, labels: _labels}, _transform, %Frame{plot: plot}) do
    px = Nx.to_number(plot[0])
    py = Nx.to_number(plot[1])
    pw = Nx.to_number(plot[2])
    ph = Nx.to_number(plot[3])

    cx = px + pw / 2.0
    cy = py + ph / 2.0
    radius = min(pw, ph) / 2.0 * 0.8

    values = Nx.to_list(y)
    n = length(values)

    y_max = Enum.max(values)
    y_min = Enum.min(values)
    span  = max(y_max - y_min, 1.0e-9)
    norm  = Enum.map(values, fn v -> (v - y_min) / span end)

    two_pi = 2.0 * :math.pi()
    # Start at top (−π/2), go clockwise
    {xs, ys} =
      Enum.with_index(norm)
      |> Enum.map(fn {v, i} ->
        angle = -:math.pi() / 2.0 + i * two_pi / n
        {cx + v * radius * :math.cos(angle),
         cy + v * radius * :math.sin(angle)}
      end)
      |> Enum.unzip()

    coords = Nx.stack([Nx.tensor(xs, type: :f64), Nx.tensor(ys, type: :f64)])

    fill = color || "#4e79a7"

    [%Geom.Path{
      coords:       coords,
      closed:       true,
      fill:         fill,
      stroke:       fill,
      stroke_width: 2,
      opacity:      0.4
    }]
  end

  @impl true
  def default_axes, do: []
end
