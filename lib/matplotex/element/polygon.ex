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

  @impl Element
  def flipy(%__MODULE__{points: point} = label, height) do
    %__MODULE__{label | points: flip_point(point, height)}
  end

  defp flip_point(point, height) do
    Enum.map(point, &flip_coord(&1, height))
  end

  defp flip_coord({x, y}, height) do
    {x, height - y}
  end

  defp assemble_point(%{points: point}) do
    for {x, y} <- point do
      "#{to_pixel(x)},#{to_pixel(y)} "
    end
  end
end
