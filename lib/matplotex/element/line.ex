defmodule Matplotex.Element.Line do
  alias Matplotex.Element
  @behaviour Element
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

  @impl true
  def assemble(line) do
    ~s(
    <line
    type="#{line.type}"
    x1="#{line.x1}"
    y1="#{line.y1}"
    x2="#{line.x2}"
    y2="#{line.y2}"
    fill="#{line.fill}"
    stroke="#{line.stroke}"
    stroke-width="#{line.stroke_width}"
    shape-rendering="#{line.shape_rendering}"
    stroke-linecap="#{line.stroke_linecap}"/>

    )
  end
end
