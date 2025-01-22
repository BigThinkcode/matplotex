defmodule Matplotex.Figure.Text do
  @moduledoc false
  alias Matplotex.Figure.Text
  alias Matplotex.Figure.Font

  defstruct [:text, :font, :height]
  # TODO: deprecate this and only use rc params for font settings
  def new(text, font) do
    %__MODULE__{text: text, font: font}
  end

  def create_text(label, opts) do
    {font_params, _opts} = Keyword.split(opts, Font.font_keys())
    font = struct(Font, font_params)

    Text.new(label, font)
  end
end
