defmodule Matplotex.Figure.Text do
  defimpl String.Chars, for: __MODULE__ do
    def to_string(text), do: text.text
  end

  defstruct [:text, :font, :height]
  # TODO: deprecate this and only use rc params for font settings
  def new(text, font) do
    %__MODULE__{text: text, font: font}
  end

  def create_text(label, opts) do
    {font_params, _opts} = Keyword.split(opts, Font.font_keys())
    font_params = Enum.into(font_params, %{})
    font = struct(Font, font_params)
    Text.new(label, font)
  end
end
