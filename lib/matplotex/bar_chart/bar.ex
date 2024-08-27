defmodule Matplotex.BarChart.Bar do
  @default_stroke_width 1
  @default_stroke "rgba(0,0,0,0)"

  @type t :: %__MODULE__{
          x: number(),
          y: number(),
          width: number(),
          height: number(),
          color: String.t(),
          stroke: String.t(),
          stroke_width: number()
        }
  defstruct [:x, :y, :width, :height, :color, stroke: @default_stroke , stroke_width: @default_stroke_width]
end
