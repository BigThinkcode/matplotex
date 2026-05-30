defmodule Matplotex.Chart.Pie do
  @moduledoc """
  Pie chart — one arc per slice.

  Data format: `dataset.y` = slice values; `dataset.labels` = slice names.
  No linear axis transform used — geometry computed directly from `frame.plot`.
  """
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Geom}

  @default_colors [
    "#4e79a7", "#f28e2b", "#e15759", "#76b7b2", "#59a14f",
    "#edc948", "#b07aa1", "#ff9da7", "#9c755f", "#bab0ac"
  ]

  @impl true
  def to_geometry(%Dataset{y: y, color: color}, _transform, %Frame{plot: plot}) do
    px = Nx.to_number(plot[0])
    py = Nx.to_number(plot[1])
    pw = Nx.to_number(plot[2])
    ph = Nx.to_number(plot[3])

    cx = px + pw / 2.0
    cy = py + ph / 2.0
    radius = min(pw, ph) / 2.0 * 0.85

    values = Nx.to_list(y)
    total  = Enum.sum(values)
    two_pi = 2.0 * :math.pi()

    {start_angles, end_angles, fills} =
      Enum.with_index(values)
      |> Enum.reduce({[], [], 0.0}, fn {v, _idx}, {sa, ea, angle} ->
        sweep = v / total * two_pi
        next  = angle + sweep
        {sa ++ [angle], ea ++ [next], next}
      end)
      |> then(fn {sa, ea, _} ->
        colors = Enum.with_index(values) |> Enum.map(fn {_, i} ->
          Enum.at(@default_colors, rem(i, length(@default_colors)))
        end)
        {sa, ea, colors}
      end)

    [%Geom.Arcs{
      center:       {cx, cy},
      outer_radius: radius,
      inner_radius: 0.0,
      start_angles: Nx.tensor(start_angles, type: :f64),
      end_angles:   Nx.tensor(end_angles, type: :f64),
      fills:        fills,
      stroke:       "white",
      stroke_width: 2
    }]
  end

  @impl true
  def default_axes, do: []
end
