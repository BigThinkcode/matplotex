defmodule Matplotex.Figure.Dataset do
  @moduledoc false
  @default_color "blue"
  @default_marker "o"
  @default_linestyle "_"
  @default_width 0.2
  @default_marker_size 1
  @default_alpha 1.0
  @line_width 2

  defstruct [
    :label,
    :pos,
    :edge_color,
    width: @default_width,
    x: [],
    y: [],
    colors: [],
    sizes: [],
    transformed: [],
    cmap: :viridis,
    color: @default_color,
    alpha: @default_alpha,
    marker: @default_marker,
    linestyle: @default_linestyle,
    marker_size: @default_marker_size,
    line_width: @line_width,
    bottom: nil
  ]

  def cast(dataset, values) do
    struct(dataset, values)
  end
end
