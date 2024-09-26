defmodule Matplotex.Figure.Font do
  @default_font_color "black"
  @default_font_family "Arial, Verdana, sans-serif"
  @default_font_style "normal"
  @default_font_size 16
  @default_font_weight "normal"
  @font_unit "pt"

  defstruct font_size: @default_font_size,
            font_style: @default_font_style,
            font_family: @default_font_family,
            font_weight: @default_font_weight,
            color: @default_font_color,
            unit_of_measurement: @font_unit

  def font_keys() do
    Map.keys(%__MODULE__{}) -- [:__struct__]
  end
end
