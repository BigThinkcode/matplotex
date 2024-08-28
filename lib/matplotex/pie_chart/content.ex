defmodule Matplotex.PieChart.Content do
  @type t() :: %__MODULE__{}
  defstruct [
    :width,
    :height,
    :radius,
    :cx,
    :cy,
    :x1,
    :y1,
    :color_palette,
    :legends,
    :stoke_width,
    :legend_frame
  ]

  defmodule LegendFrame do
    defstruct [:x, :y, :uheight, :uwidth]
  end
end
