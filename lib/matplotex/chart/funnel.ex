defmodule Matplotex.Chart.Funnel do
  @moduledoc """
  Funnel chart — horizontal bars centred on the x-axis, widths from y values.

  Data format: `dataset.y` = stage values (largest first); `dataset.labels` = stage names.
  Each stage is a centred trapezoid; adjacent stages share the same horizontal centre.
  """
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Geom}

  @impl true
  def to_geometry(%Dataset{y: y, color: color}, _transform, %Frame{plot: plot}) do
    px = Nx.to_number(plot[0])
    py = Nx.to_number(plot[1])
    pw = Nx.to_number(plot[2])
    ph = Nx.to_number(plot[3])

    values = Nx.to_list(y)
    n = length(values)
    max_v = Enum.max(values)
    bar_h = ph / max(n, 1)
    cx    = px + pw / 2.0

    default_colors = [
      "#4e79a7", "#f28e2b", "#e15759", "#76b7b2", "#59a14f",
      "#edc948", "#b07aa1", "#ff9da7", "#9c755f", "#bab0ac"
    ]

    rects_data =
      Enum.with_index(values)
      |> Enum.map(fn {v, i} ->
        bar_w = v / max_v * pw
        bar_x = cx - bar_w / 2.0
        bar_y = py + i * bar_h
        [bar_x, bar_y, bar_w, bar_h * 0.9]
      end)

    fills =
      Enum.with_index(values)
      |> Enum.map(fn {_, i} ->
        color || Enum.at(default_colors, rem(i, length(default_colors)))
      end)

    xywh = rects_data |> Nx.tensor(type: :f64) |> Nx.transpose()
    [%Geom.Rects{xywh: xywh, fills: fills}]
  end

  @impl true
  def default_axes, do: []
end
