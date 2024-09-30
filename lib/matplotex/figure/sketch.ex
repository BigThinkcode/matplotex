defmodule Matplotex.Figure.Sketch do
  alias Matplotex.Figure
  @dpi 96

  def call(%Figure{axes: %{element: elements}, figsize: {width, height}}) do
    elements
    |> build_elements()
    |> wrap_with_tag(width * @dpi, height * @dpi)
  end

  def call(_) do
    raise(ArgumentError, message: "missing some keys to pattern match")
  end

  defp build_elements(elements) do
    "#{for element <- elements do
      svgfy_element(element)
    end}"
  end

  defp svgfy_element(%module{} = element), do: module.assemble(element)

  defp wrap_with_tag(svg, width, height) do
    ~s(<svg width="#{width}"
      height="#{height}"
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      style="top: 0px;
      left: 0px;
      position: absolute;">
      <g>
      #{svg}
      </g>
      </svg>
      )
  end
end
