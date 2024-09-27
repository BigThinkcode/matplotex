defmodule Matplotex.Figure.Text do
  defstruct [:text, :font]
  # TODO: deprecate this and only use rc params for font settings
  def new(text, font) do
    %__MODULE__{text: text, font: font}
  end
end
