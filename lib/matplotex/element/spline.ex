defmodule Matplotex.Element.Spline do
  alias Matplotex.Element
  use Element

  defstruct [:type, :moveto, :cubic, :smooths, :fill, :stroke, :stroke_width]

  @impl Element
  def assemble(element) do
    """
     <path d="M #{to_pixel(element.moveto)}}
     C #{points(element.cubic)}
     #{smooth_beizer(element.smooths)}
      fill="#{element.fill}"
      stroke="#{element.storke}"
      stroke-width="#{element.stroke_width}" />
    """
  end

  defp points(points) do
    for point <- points do
      "#{to_pixel(point)}"
    end
  end

  defp smooth_beizer(points) do
    for point <- points do
      "S #{points(point)}"
    end
  end
end
