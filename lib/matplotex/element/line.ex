defmodule Matplotex.Element.Line do
  @type t() :: %__MODULE__{
          type: String.t(),
          x1: number(),
          y1: number(),
          x2: number(),
          y2: number(),
          fill: String.t(),
          stroke: String.t(),
          stroke_width: number(),
          shape_rendering: number(),
          stroke_linecap: number()
        }
  defstruct [
    :type,
    :x1,
    :y1,
    :x2,
    :y2,
    stroke: "black",
    fill: "rgba(0,0,0,0)",
    stroke_width: "3",
    shape_rendering: "crispEdges",
    stroke_linecap: "square"
  ]
end
