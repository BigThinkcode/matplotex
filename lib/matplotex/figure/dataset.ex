defmodule Matplotex.Figure.Dataset do
  @default_color "blue"
  @default_marker "o"
  @default_linestyle "_"
  @default_width 0.2
  @default_marker_size 3.5

  defstruct [
    :label,
    :pos,
    width: @default_width,
    x: [],
    y: [],
    transformed: [],
    color: @default_color,
    marker: @default_marker,
    linestyle: @default_linestyle,
    marker_size: @default_marker_size
  ]

  def cast(dataset, values) do
    struct(dataset, values)
  end
end
