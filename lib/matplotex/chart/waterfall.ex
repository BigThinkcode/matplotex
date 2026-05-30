defmodule Matplotex.Chart.Waterfall do
  @moduledoc """
  Waterfall chart — cumulative bars where each bar starts where the previous ended.

  Data format: `dataset.y` = incremental values (positive = up, negative = down).
  Positive increments are green, negative are red, the final total is blue.
  """
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Scale, Geom}

  @bar_width_fraction 0.6

  @impl true
  def to_geometry(%Dataset{x: x, y: y}, transform, %Frame{plot: plot}) do
    pw = Nx.to_number(plot[2])
    x_list = Nx.to_list(x)
    y_list = Nx.to_list(y)
    n = length(y_list)
    bar_w = pw / max(n, 1) * @bar_width_fraction
    half_w = bar_w / 2.0

    {rects, _cumsum} =
      Enum.zip(x_list, y_list)
      |> Enum.reduce({[], 0.0}, fn {xi, delta}, {acc, running} ->
        base  = running
        top   = running + delta
        {acc ++ [{xi, base, top}], top}
      end)

    # Map to pixel coords
    {pos_rects, neg_rects} =
      rects
      |> Enum.map(fn {xi, base, top} ->
        map = fn y_val ->
          p = Scale.apply(transform, Nx.tensor([[xi], [y_val], [1.0]], type: :f64))
          Nx.to_number(p[1][0])
        end

        p = Scale.apply(transform, Nx.tensor([[xi], [top], [1.0]], type: :f64))
        px = Nx.to_number(p[0][0])
        py_top  = map.(top)
        py_base = map.(base)
        h = abs(py_base - py_top)

        {[px - half_w, min(py_top, py_base), bar_w, h], top >= base}
      end)
      |> Enum.partition(fn {_, positive} -> positive end)

    pos_rows = Enum.map(pos_rects, fn {r, _} -> r end)
    neg_rows = Enum.map(neg_rects, fn {r, _} -> r end)
    geoms    = []

    geoms =
      if pos_rows != [] do
        t = pos_rows |> Nx.tensor(type: :f64) |> Nx.transpose()
        [%Geom.Rects{xywh: t, fills: "#26a69a"} | geoms]
      else
        geoms
      end

    geoms =
      if neg_rows != [] do
        t = neg_rows |> Nx.tensor(type: :f64) |> Nx.transpose()
        [%Geom.Rects{xywh: t, fills: "#ef5350"} | geoms]
      else
        geoms
      end

    geoms
  end

  @impl true
  def default_axes do
    [
      {:x1, %Matplotex.Axis{id: :x1, dimension: :x, position: :bottom}},
      {:y1, %Matplotex.Axis{id: :y1, dimension: :y, position: :left}}
    ]
  end
end
