defmodule Matplotex.Figure.Font do
  @default_font_color "black"
  @default_font_family "Arial, Verdana, sans-serif"
  @default_font_style "normal"
  @default_font_size "16pt"
  @default_font_weight "normal"

  defstruct [font_size: @default_font_size, font_style: @default_font_style, font_family: @default_font_family, font_weight: @default_font_weight, color: @default_font_color]

  def font_keys() do
    [:font_size, :font_style, :font_family, :font_weight, :color]
  end
end
