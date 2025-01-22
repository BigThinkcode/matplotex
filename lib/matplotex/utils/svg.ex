defmodule Matplotex.Utils.Svg do
  @moduledoc false

  def wrap_with_frame(%{width: width, height: height}, svg) do
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
