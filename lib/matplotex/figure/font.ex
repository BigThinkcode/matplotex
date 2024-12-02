defmodule Matplotex.Figure.Font do
  @default_font_color "black"
  @default_font_family "Arial, Verdana, sans-serif"
  @default_font_style "normal"
  @default_font_size 16
  @default_font_weight "normal"
  @font_unit "pt"
  @pt_to_inch_ratio 1 / 72
  @text_rotation 0
  @flate 0

  defstruct font_size: @default_font_size,
            font_style: @default_font_style,
            font_family: @default_font_family,
            font_weight: @default_font_weight,
            fill: @default_font_color,
            unit_of_measurement: @font_unit,
            pt_to_inch_ratio: @pt_to_inch_ratio,
            rotation: @text_rotation,
            flate: @flate

  def font_keys() do
    Map.keys(%__MODULE__{}) -- [:__struct__]
  end

  def create(font_size) when is_number(font_size) do
    %__MODULE__{font_size: font_size}
  end

  def create(params) do
    struct(__MODULE__, params)
  end

  def update(font, params, element) do
    update_font(font, params, element)
  end
  defp update_font(font, params, element) do
    font
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.reduce(font, fn key, acc ->
      existing_value = Map.get(font, key)
      value = Map.get(params, :"#{element}_#{key}", existing_value)
      Map.put(acc, key, value)
    end)
  end
end
