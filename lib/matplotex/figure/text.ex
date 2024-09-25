defmodule Matplotex.Figure.Text do
  defstruct [:text, :font]

  def new(text, font) do
    %__MODULE__{text: text, font: font}
  end
end
