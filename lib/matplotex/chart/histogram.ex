defmodule Matplotex.Chart.Histogram do
  @moduledoc """
  Histogram — bins raw samples into equal-width buckets and draws a bar per bin.

  Data format: `dataset.x` = raw sample values (1D).
  Bin count defaults to Sturges' rule: `ceil(log2(n) + 1)`.
  """
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Scale, Stat, Geom}

  @impl true
  def to_geometry(%Dataset{x: x, color: color}, transform, %Frame{}) do
    n = Nx.size(x)
    bins = ceil(:math.log2(n) + 1)

    {edges, counts} = Stat.histogram(x, bins)

    edges_list  = Nx.to_list(edges)
    counts_list = Nx.to_list(counts)

    {rects_xywh, _} =
      Enum.zip(Enum.zip(edges_list, Enum.drop(edges_list, 1)), counts_list)
      |> Enum.reduce({[], nil}, fn {{left, right}, count}, {acc, _prev} ->
        ones = Nx.tensor([1.0, 1.0], type: :f64)

        # Transform bin left edge and count as y
        p_top  = Scale.apply(transform, Nx.tensor([[left], [count], [1.0]], type: :f64))
        p_base = Scale.apply(transform, Nx.tensor([[left], [0.0],  [1.0]], type: :f64))
        p_right = Scale.apply(transform, Nx.tensor([[right], [0.0], [1.0]], type: :f64))

        x_px     = Nx.to_number(p_top[0][0])
        y_px     = Nx.to_number(p_top[1][0])
        w_px     = Nx.to_number(p_right[0][0]) - x_px
        h_px     = Nx.to_number(p_base[1][0])  - y_px

        {acc ++ [[x_px, y_px, w_px, h_px]], nil}
      end)

    xywh_tensor = rects_xywh |> Nx.tensor(type: :f64) |> Nx.transpose()

    [%Geom.Rects{
      xywh:   xywh_tensor,
      fills:  color || "#4e79a7",
      stroke: "white"
    }]
  end

  @impl true
  def default_axes do
    [
      {:x1, %Matplotex.Axis{id: :x1, dimension: :x, position: :bottom, label: "Value"}},
      {:y1, %Matplotex.Axis{id: :y1, dimension: :y, position: :left,   label: "Count"}}
    ]
  end
end
