defmodule Matplotex.Figure.Sketch do
  alias Matplotex.Figure
  @dpi 96

  def call({stream, %Figure{figsize: {width, height}}}) do
    stream
    |> Stream.map(fn %module{} = elem ->
      elem = module.flipy(elem, height)
      module.assemble(elem)
    end)
    |> wrap_with_tag(width * @dpi, height * @dpi)
  end

  def call(%Figure{axes: %{element: elements}, figsize: {width, height}}) do
    elements
    # |> flipy(height)
    |> build_elements()
    |> wrap_with_tag(width * @dpi, height * @dpi)
  end

  def call(_) do
    raise(ArgumentError, message: "invalid figure")
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

  defp flipy(elements, height) do
    Enum.map(elements, fn %module{} = elem ->
      module.flipy(elem, height)
    end)
  end
end
