defmodule Matplotex.Element.Label do
  alias Matplotex.Element
  @behaviour Element
  @default_fill "black"
  @default_font_family "Arial, Verdana, sans-serif"
  @default_font_style "normal"
  @default_dominant_baseline "hanging"
  @default_font_size "16pt"
  @default_font_weight "normal"

  @type word() :: String.t()
  @type t() :: %__MODULE__{
          type: String.t(),
          x: number(),
          y: number(),
          font_size: word(),
          font_weight: word(),
          text: word(),
          fill: word(),
          font_family: word(),
          font_style: word(),
          dominant_baseline: word(),
          rotate: number()
        }
  defstruct [
    :type,
    :x,
    :y,
    :text,
    :rotate,
    font_size: @default_font_size,
    font_weight: @default_font_weight,
    fill: @default_fill,
    font_family: @default_font_family,
    font_style: @default_font_style,
    dominant_baseline: @default_dominant_baseline
  ]

  def assemble(label) do
    """
        <text tag="#{label.type}"
         fill="#{label.fill}"
         x="#{label.x}"
         y="#{label.y}"
         font-size="#{label.font_size}"
         font-weight="#{label.font_weight}"
         font-family="#{label.font_family}"
         font-style="#{label.font_style}"
         transform="#{rotate(label.rotate, label.x, label.y)}"
         dominant-baseline="#{label.dominant_baseline}">
         #{label.text}
        </text>
    """
  end

  defp rotate(nil, _, _), do: nil
  defp rotate(rotate, x, y), do: "rotate(#{rotate}, #{x}, #{y})"
end
