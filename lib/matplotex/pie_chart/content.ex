defmodule Matplotex.PieChart.Content do
  @type t() :: %__MODULE__{}

  @labels_default false
  @legends_default true
  defstruct [
    :width,
    :height,
    :radius,
    :cx,
    :cy,
    :x1,
    :y1,
    :color_palette,
    :stoke_width,
    :legend_frame,
    labels: @labels_default,
    legends: @legends_default
  ]

  defmodule LegendFrame do
    defstruct [:x, :y, :uheight, :uwidth]
  end
end
