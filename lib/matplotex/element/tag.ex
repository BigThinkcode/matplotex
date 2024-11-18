defmodule Matplotex.Element.Tag do
  alias Matplotex.Element
  use Element
  defstruct [:width, :height]

  def assemble(element) do
    ~s(<svg width="#{to_pixel(element.width)}"
    height="#{to_pixel(element.height)}"
    version="1.1"
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    style="top: 0px;
    left: 0px;
    position: absolute;">
    <g>
    )
  end
  def flipy(element, _height) do
    element
  end

end
