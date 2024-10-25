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
      stroke: @default_stroke,
      stroke_width: @default_stroke_width
    ]
  @impl Element
  def assemble(rect) do
    ~s(
      <rect stroke="#{rect.stroke}"
      fill="#{rect.color}"
      x="#{rect.x}"
      y="#{rect.y}"
      width="#{rect.width}"
      height="#{rect.height}"
      stroke-width="#{rect.stroke_width}"
      filter="">
      </rect>)
  end


  def get_x(%{x: x}), do: to_pixel(x)
  def get_y(%{y: y}), do: to_pixel(y)
  @impl Element
  def flipy(%__MODULE__{y: y} = label, height) do
    %__MODULE__{label | y: height - y}
  end
end
