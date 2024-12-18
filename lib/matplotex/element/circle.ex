defmodule Matplotex.Element.Circle do
  alias Matplotex.Element
  use Element

  @default_stroke_width 0
  @default_stroke "rgba(0,0,0,0)"
  defstruct [
    :type,
    :cx,
    :cy,
    :r,
    :fill,
    stroke: @default_stroke,
    stroke_width: @default_stroke_width
  ]

  @impl Element
  def assemble(circle) do
    ~s(
      <circle
       type="#{circle.type}"
       cx="#{get_cx(circle)}px"
       cy="#{get_cy(circle)}px"
       r="#{get_r(circle)}"
       fill="#{circle.fill}" stroke="#{circle.stroke}"
       stroke_width="#{circle.stroke_width}"
      >
      </circle>
    )
  end

  def get_cx(%{cx: x}), do: to_pixel(x)
  def get_cy(%{cy: y}), do: to_pixel(y)
  def get_r(%{r: r}), do: to_pixel(r)
  @impl Element
  def flipy(%__MODULE__{cy: y} = circle, height) do
    %__MODULE__{circle | cy: height - y}
  end
end
