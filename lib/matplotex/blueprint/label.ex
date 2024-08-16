defmodule Matplotex.Blueprint.Label do
  @type t() :: %__MODULE__{}
  defstruct [:axis, :x, :y, :font_size, :font_weight, :text]
end
