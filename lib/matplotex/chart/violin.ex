defmodule Matplotex.Chart.Violin do
  @moduledoc """
  Violin plot — mirrored KDE density per group.

  Data format: same as `Chart.Box` — `dataset.x` = group, `dataset.y` = samples.
  """
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Scale, Stat, Geom}

  @violin_width_fraction 0.4

  @impl true
  def to_geometry(%Dataset{x: x, y: y, color: color}, transform, %Frame{plot: plot}) do
    pw = Nx.to_number(plot[2])
    x_list = Nx.to_list(x)
    y_list = Nx.to_list(y)
    n_groups = x_list |> Enum.uniq() |> length()
    half_w = pw / max(n_groups, 1) * @violin_width_fraction

    groups = Enum.zip(x_list, y_list) |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    fill = color || "#4e79a7"

    Enum.flat_map(groups, fn {gx, samples} ->
      samples_t = Nx.tensor(samples, type: :f64)
      {_eval_x, densities} = Stat.kde(samples_t, 60)

      # Map density values to pixel widths (normalize to half_w)
      d_max = densities |> Nx.reduce_max() |> Nx.to_number()
      norm_d = if d_max > 0, do: Nx.divide(densities, Nx.tensor(d_max, type: :f64)), else: densities

      eval_ys = Nx.linspace(
        samples_t |> Nx.reduce_min() |> Nx.to_number(),
        samples_t |> Nx.reduce_max() |> Nx.to_number(),
        n: 60
      ) |> Nx.to_list()

      norm_d_list = Nx.to_list(norm_d)

      # Build right side (x + density_width) and left side (x - density_width)
      {right_xs, right_ys} =
        Enum.zip(norm_d_list, eval_ys)
        |> Enum.map(fn {d, vy} ->
          p = Scale.apply(transform, Nx.tensor([[gx], [vy], [1.0]], type: :f64))
          px = Nx.to_number(p[0][0])
          py = Nx.to_number(p[1][0])
          {px + d * half_w, py}
        end)
        |> Enum.unzip()

      {left_xs, left_ys} =
        Enum.zip(norm_d_list, eval_ys)
        |> Enum.reverse()
        |> Enum.map(fn {d, vy} ->
          p = Scale.apply(transform, Nx.tensor([[gx], [vy], [1.0]], type: :f64))
          px = Nx.to_number(p[0][0])
          py = Nx.to_number(p[1][0])
          {px - d * half_w, py}
        end)
        |> Enum.unzip()

      all_x = Nx.tensor(right_xs ++ left_xs, type: :f64)
      all_y = Nx.tensor(right_ys ++ left_ys, type: :f64)

      [%Geom.Path{
        coords:       Nx.stack([all_x, all_y]),
        closed:       true,
        fill:         fill,
        stroke:       fill,
        stroke_width: 1,
        opacity:      0.7
      }]
    end)
  end

  @impl true
  def default_axes do
    [
      {:x1, %Matplotex.Axis{id: :x1, dimension: :x, position: :bottom}},
      {:y1, %Matplotex.Axis{id: :y1, dimension: :y, position: :left}}
    ]
  end
end
