defmodule Matplotex.Element.Rect do
  @moduledoc false
  alias Matplotex.Element

  @default_stroke_width 2
  @default_stroke "black"
  @default_opacity 1.0
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
    fill_opacity: @default_opacity,
    stroke_opacity: @default_opacity,
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
      stroke-opacity="#{rect.stroke_opacity}"
      fill-opacity="#{rect.fill_opacity}"
      filter="">
      </rect>)
  end

  def get_x(%{x: x}), do: to_pixel(x)
  def get_y(%{y: y}), do: to_pixel(y)
  def get_width(%{width: width}), do: to_pixel(width)
  def get_height(%{height: height}), do: to_pixel(height)
end
