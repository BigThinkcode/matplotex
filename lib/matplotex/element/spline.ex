defmodule Matplotex.Element.Spline do
@moduledoc false
  alias Matplotex.Element
  use Element
  @default_stroke_width 2
  @default_stroke "black"

  @fill "none"
  defstruct [
    :type,
    :moveto,
    :cubic,
    :smooths,
    fill: @fill,
    stroke: @default_stroke,
    stroke_width: @default_stroke_width
  ]

  @impl Element
  def assemble(element) do
    """
     <path d="M #{to_pixel(element.moveto)}
     C #{points(element.cubic)} #{smooth_beizer(element.smooths)} "
      fill="#{element.fill}"
      stroke="#{element.stroke}"
      stroke-width="#{element.stroke_width}" />
    """
  end

  defp points(points) do
    for point <- points do
      "#{to_pixel(point)} "
    end
  end

  defp smooth_beizer(points) do
    for point <- points do
      "S #{points(point)}"
    end
  end
end
