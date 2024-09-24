defmodule Matplotex.Figure.Legend do
  defstruct [:labels, :title, :colors, :position, :size]

  @type t() :: %__MODULE__{labels: list(), title: String.t(),position: atom(),size: tuple()}
end
