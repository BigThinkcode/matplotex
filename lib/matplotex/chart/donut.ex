defmodule Matplotex.Chart.Donut do
  @moduledoc "Donut chart — pie with a hollow centre (inner_radius > 0)."
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Geom}

  @impl true
  def to_geometry(%Dataset{y: y} = ds, transform, %Frame{plot: plot} = frame) do
    [%Geom.Arcs{} = arc] = Matplotex.Chart.Pie.to_geometry(ds, transform, frame)
    pw = Nx.to_number(plot[2])
    ph = Nx.to_number(plot[3])
    inner = min(pw, ph) / 2.0 * 0.85 * 0.55
    [%{arc | inner_radius: inner}]
  end

  @impl true
  def default_axes, do: []
end
