defmodule Matplotex.Element.Line do
  alias Matplotex.Element
  use Element

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
    linestyle: "_",
    stroke: "black",
    fill: "rgba(0,0,0,0)",
    stroke_width: "2",
    shape_rendering: "geometricPrecision",
    stroke_linecap: "square"
  ]

  @impl true
  def assemble(line) do
    ~s(
    <line
    type="#{line.type}"
    x1="#{get_x1(line)}"
    y1="#{get_y1(line)}"
    x2="#{get_x2(line)}"
    y2="#{get_y2(line)}"
    fill="#{line.fill}"
    stroke="#{line.stroke}"
    stroke-width="#{line.stroke_width}"
    shape-rendering="#{line.shape_rendering}"
    stroke-linecap="#{line.stroke_linecap}"
    stroke-dasharray="#{stroke_dasharray(line)}"
    />

    )
  end

  def get_x1(%{x1: x1}), do: to_pixel(x1)
  def get_x2(%{x2: x2}), do: to_pixel(x2)
  def get_y1(%{y1: y1}), do: to_pixel(y1)
  def get_y2(%{y2: y2}), do: to_pixel(y2)

  defp stroke_dasharray(%{linestyle: "_"}), do: nil

  defp stroke_dasharray(%{linestyle: "--"}) do
    "10, 5"
  end

  defp stroke_dasharray(%{linestyle: "-."}) do
    "10, 2, 3, 2, 10"
  end
end
