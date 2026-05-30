defmodule Matplotex.Chart.Step do
  @moduledoc "Step chart — horizontal then vertical line segments (staircase)."
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Scale, Geom}

  @impl true
  def to_geometry(%Dataset{x: x, y: y, color: color}, transform, %Frame{}) do
    order = Nx.argsort(x)
    x_s = Nx.take(x, order) |> Nx.to_list()
    y_s = Nx.take(y, order) |> Nx.to_list()

    # Build step points: for each pair, emit [xi, yi] then [xi+1, yi]
    {step_xs, step_ys} =
      Enum.zip(x_s, y_s)
      |> Enum.zip(Enum.drop(x_s, 1))
      |> Enum.flat_map(fn {{xi, yi}, xi_next} ->
        [{xi, yi}, {xi_next, yi}]
      end)
      |> Enum.unzip()
      |> then(fn {xs, ys} ->
        # append last original point
        {xs ++ [List.last(x_s)], ys ++ [List.last(y_s)]}
      end)

    n = length(step_xs)
    ones = Nx.broadcast(Nx.tensor(1.0, type: :f64), {n})
    pts  = Nx.stack([Nx.tensor(step_xs, type: :f64), Nx.tensor(step_ys, type: :f64), ones])
    pixel = Scale.apply(transform, pts)

    [%Geom.Path{
      coords:       pixel,
      stroke:       color || "#4e79a7",
      stroke_width: 2,
      fill:         "none"
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
