defmodule Matplotex.Element.Slice do
  alias Matplotex.Element
  use Element

  defstruct [
    :type,
    :x1,
    :y1,
    :x2,
    :y2,
    :cx,
    :cy,
    :data,
    :percentage,
    :radius,
    :color,
    :label,
    :legend
  ]

  # TODO: change the fucntion name assemble to to_svg

  @impl Element
  def assemble(slice) do
    """
    <path d="M #{get_x1(slice)} #{get_y1(slice)}
     A #{get_radius(slice)} #{get_radius(slice)} 0 0 1 #{get_x2(slice)} #{get_y2(slice)}
     L #{get_cx(slice)} #{get_cy(slice)}
     Z" fill="#{slice.color}" />
    """
  end

  def get_x1(%{x1: x1}), do: to_pixel(x1)
  def get_x2(%{x2: x2}), do: to_pixel(x2)
  def get_y1(%{y1: y1}), do: to_pixel(y1)
  def get_y2(%{y2: y2}), do: to_pixel(y2)
  def get_cx(%{cx: cx}), do: to_pixel(cx)
  def get_cy(%{cy: cy}), do: to_pixel(cy)
  def get_radius(%{radius: radius}), do: to_pixel(radius)
end
