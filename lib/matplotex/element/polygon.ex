defmodule Matplotex.Element.Polygon do
  alias Matplotex.Element
  use Element
  @default_fill "blue"

  defstruct [:type, :points, fill: @default_fill]

  @impl Element
  def assemble(polygon) do
    ~s(
    <polygon points="#{assemble_point(polygon)}"
     fill="#{polygon.fill}"
     type="#{polygon.type}"
     />
    )
  end

  defp assemble_point(%{points: point}) do
    for {x, y} <- point do
      "#{to_pixel(x)},#{to_pixel(y)} "
    end
  end
end
