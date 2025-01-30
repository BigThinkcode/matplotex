defmodule Matplotex.Element.Cmap do
  alias Matplotex.Element.Rect
  alias Matplotex.Element
  use Element

  defstruct type: "figure.cmap",
            id: nil,
            cmap: [],
            container: %Rect{}

  @impl Element
  def assemble(element) do
    ~s(<defs>
    <linearGradient id="#{element.id}" x1="0%" y1="0%" x2="0%" y2="100%">
    #{for stp <- element.cmap do
      tag_stop(stp)
    end}
    </linearGradient>
  </defs>
  #{Element.assemble(element.container)})
  end

  def tag_stop(%{offset: offset, color: color, opacity: opacity}) do
    ~s(<stop offset="#{offset}%" style="stop-color:#{color};stop-opacity:#{opacity}" />)
  end

  def color_gradient(%__MODULE__{container: container} = element) do
    %__MODULE__{element | container: %{container | color: "url(##{element.id})"}}
  end

  def get_x(%{x: x}), do: to_pixel(x)
  def get_y(%{y: y}), do: to_pixel(y)
  def get_width(%{width: width}), do: to_pixel(width)
  def get_height(%{height: height}), do: to_pixel(height)
end
