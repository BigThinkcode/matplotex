defmodule Matplotex.BarChart.Bar do
  @type t :: %__MODULE__{
          x: number(),
          y: number(),
          width: number(),
          height: number(),
          color: String.t(),
          stroke: String.t()
        }
  defstruct [:x, :y, :width, :height, :color, :stroke]
end
