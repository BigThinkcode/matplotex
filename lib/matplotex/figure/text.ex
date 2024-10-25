defmodule Matplotex.Figure.Text do
  defimpl String.Chars, for: __MODULE__ do
    def to_string(text), do: text.text
  end

  defstruct [:text, :font, :height]
  # TODO: deprecate this and only use rc params for font settings
  def new(text, font) do
    %__MODULE__{text: text, font: font}
  end
end
