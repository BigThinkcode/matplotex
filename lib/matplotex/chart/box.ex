defmodule Matplotex.Chart.Box do
  @moduledoc """
  Box plot — five-number summary per group.

  Data format: `dataset.x` = group index (integer), `dataset.y` = raw samples.
  Multiple groups are supported via multiple datasets or by group column.
  """
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Scale, Stat, Geom}

  @box_width_fraction 0.5

  @impl true
  def to_geometry(%Dataset{x: x, y: y, color: color}, transform, %Frame{plot: plot}) do
    pw = Nx.to_number(plot[2])
    n_groups = x |> Nx.to_list() |> Enum.uniq() |> length()
    box_w = pw / max(n_groups, 1) * @box_width_fraction

    # Group y values by x
    x_list = Nx.to_list(x)
    y_list = Nx.to_list(y)

    groups =
      Enum.zip(x_list, y_list)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

    segs = []
    rects = []

    {segs, rects} =
      Enum.reduce(groups, {segs, rects}, fn {gx, samples}, {s_acc, r_acc} ->
        {mn, q1, med, q3, mx} = Stat.five_number_summary(Nx.tensor(samples, type: :f64))

        ones = Nx.tensor([1.0], type: :f64)
        px = Scale.apply(transform, Nx.tensor([[gx], [med], [1.0]], type: :f64))
        px_x = Nx.to_number(px[0][0])

        map_y = fn v ->
          p = Scale.apply(transform, Nx.tensor([[gx], [v], [1.0]], type: :f64))
          Nx.to_number(p[1][0])
        end

        py_min = map_y.(mn)
        py_q1  = map_y.(q1)
        py_med = map_y.(med)
        py_q3  = map_y.(q3)
        py_max = map_y.(mx)

        half_w = box_w / 2.0

        # Box rect: from q1 to q3
        box = [px_x - half_w, py_q3, box_w, py_q1 - py_q3]

        # Whisker segments: min→q1 and q3→max, plus caps
        whisker_segs = [
          [px_x, py_q1,      px_x, py_min],      # lower whisker
          [px_x, py_q3,      px_x, py_max],      # upper whisker
          [px_x - half_w * 0.5, py_min, px_x + half_w * 0.5, py_min],  # lower cap
          [px_x - half_w * 0.5, py_max, px_x + half_w * 0.5, py_max],  # upper cap
          [px_x - half_w, py_med, px_x + half_w, py_med]               # median line
        ]

        new_rects = r_acc ++ [box]
        new_segs  = s_acc ++ whisker_segs

        {new_segs, new_rects}
      end)

    fill  = color || "#4e79a7"
    geoms = []

    geoms =
      if rects != [] do
        xywh = rects |> Nx.tensor(type: :f64) |> Nx.transpose()
        [%Geom.Rects{xywh: xywh, fills: fill, stroke: fill} | geoms]
      else
        geoms
      end

    geoms =
      if segs != [] do
        x1y1x2y2 = segs |> Nx.tensor(type: :f64) |> Nx.transpose()
        [%Geom.Segments{x1y1x2y2: x1y1x2y2, stroke: fill, stroke_width: 1.5} | geoms]
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
