defmodule Matplotex.Figure.Radial.Dataset do
  defstruct sizes: [],
            labels: [],
            colors: [],
            start_angle: -:math.pi() / 2,
            radius: 0,
            formatter: nil,
            edge_color: nil

  def cast(dataset, params) do
    struct(dataset, params)
  end
end
