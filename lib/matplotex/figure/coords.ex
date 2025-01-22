defmodule Matplotex.Figure.Coords do
  @moduledoc false
  defstruct [
    :title,
    :x_label,
    :x_ticks,
    :y_label,
    :y_ticks,
    :bottom_left,
    :top_left,
    :bottom_right,
    :top_right,
    :hgrids,
    :vgrids
  ]
end
