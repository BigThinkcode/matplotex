defmodule Matplotex.Figure.Radial.Dataset do
  defstruct [
    :sizes,
    :labels,
    :colors,
    :start_angle,
    :radius,
    :formatter,
    :edge_color

  ]

  def cast(dataset, params) do
    struct(dataset, params)
  end
end
