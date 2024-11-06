defmodule Matplotex.Element.Rect do
  alias Matplotex.Element

  @default_stroke_width 1
  @default_stroke "rgba(0,0,0,0)"
  use Element

  @type t :: %__MODULE__{
          x: number(),
          y: number(),
          width: number(),
          height: number(),
          color: String.t(),
          stroke: String.t(),
          stroke_width: number()
        }
  defstruct [
    :x,
    :y,
    :width,
    :height,
    :color,
    :type,
    stroke: @default_stroke,
    stroke_width: @default_stroke_width
  ]

  @impl Element
  def assemble(rect) do
    ~s(
      <rect
      type="#{rect.type}"
      stroke="#{rect.stroke}"
      fill="#{rect.color}"
      x="#{get_x(rect)}"
      y="#{get_y(rect)}"
      width="#{get_width(rect)}"
      height="#{get_height(rect)}"
      stroke-width="#{rect.stroke_width}"
      filter="">
      </rect>)
  end

  def get_x(%{x: x}), do: to_pixel(x)
  def get_y(%{y: y}), do: to_pixel(y)
  def get_width(%{width: width}), do: to_pixel(width)
  def get_height(%{height: height}), do: to_pixel(height)
  @impl Element
  def flipy(%__MODULE__{y: y} = rect, height) do
    %__MODULE__{rect | y: height - y}
  end
end
