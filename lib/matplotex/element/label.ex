defmodule Matplotex.Element.Label do
  alias Matplotex.Element
  use Element
  @default_fill "black"
  @default_font_family "Arial, Verdana, sans-serif"
  @default_font_style "normal"
  @default_dominant_baseline "hanging"
  @default_font_size "16pt"
  @default_font_weight "normal"
  @default_text_anchor "middle"
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
    dominant_baseline: @default_dominant_baseline,
    text_anchor: @default_text_anchor
  ]

  @impl true
  def assemble(label) do
    """
        <text tag="#{label.type}"
         fill="#{label.fill}"
         x="#{get_x(label)}"
         y="#{get_y(label)}"
         font-size="#{label.font_size}"
         font-weight="#{label.font_weight}"
         font-family="#{label.font_family}"
         font-style="#{label.font_style}"
         transform="#{rotate(label)}"
         dominant-baseline="#{label.dominant_baseline}"
         text-anchor="#{label.text_anchor}"
         >
         #{label.text}
        </text>
    """
  end

  def cast_label(label, font) do
    font = Map.from_struct(font)
    struct(label, font)
  end

  defp rotate(%{rotate: nil}), do: nil

  defp rotate(%{rotate: rotate, x: x, y: y}),
    do: "rotate(#{rotate}, #{to_pixel(x)}, #{to_pixel(y)})"

  def get_x(%{x: x}), do: to_pixel(x)
  def get_y(%{y: y}), do: to_pixel(y)
  def get_width(%{width: width}), do: to_pixel(width)
  def get_height(%{height: height}), do: to_pixel(height)
  @impl Element
  def flipy(%__MODULE__{y: y} = label, height) do
    %__MODULE__{label | y: height - y}
  end
end
