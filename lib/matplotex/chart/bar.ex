defmodule Matplotex.Chart.Bar do
  @moduledoc """
  Bar chart — one rectangle per data point.

  Bar width is derived from the x-axis pixel spacing between adjacent ticks.
  Each bar runs from y=0 (baseline) to y=value.
  """
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Scale, Geom}

  @bar_width_fraction 0.7

  @impl true
  def to_geometry(%Dataset{x: x, y: y, color: color}, transform, %Frame{plot: plot}) do
    n = Nx.size(x)

    # Transform bar tops: [x, y, 1]
    ones = Nx.broadcast(Nx.tensor(1.0, type: :f64), {n})
    tops = Scale.apply(transform, Nx.stack([x, y, ones]))

    # Transform baseline: y=0
    zeros = Nx.broadcast(Nx.tensor(0.0, type: :f64), {n})
    bases = Scale.apply(transform, Nx.stack([x, zeros, ones]))

    px = Nx.to_number(plot[0])
    pw = Nx.to_number(plot[2])

    # Bar width from plot width ÷ n, scaled by fraction
    bar_width = pw / max(n, 1) * @bar_width_fraction

    # rect x = pixel_x - bar_width/2
    bar_xs = Nx.subtract(tops[0], Nx.tensor(bar_width / 2.0, type: :f64))

    # rect height = base_y - top_y  (SVG: y increases downward)
    heights = Nx.subtract(bases[1], tops[1])

    # Stack into {4, n}: [x, y, w, h] per bar
    bar_w_col = Nx.broadcast(Nx.tensor(bar_width, type: :f64), {n})
    xywh = Nx.stack([bar_xs, tops[1], bar_w_col, heights])

    [%Geom.Rects{
      xywh:  xywh,
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
