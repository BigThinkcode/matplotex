defmodule Matplotex.LinePlot.Content do
  @line_width 3
  defstruct [:width, :height, :x, :y, :x_max, :y_max, :label_offset, :label_suffix, :color_palette, line_width: @line_width]

end
