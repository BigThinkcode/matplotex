defmodule Matplotex.BarChart.Element do
  @type t :: %__MODULE__{labels: list(), ticks: list(), bars: list()}
  defstruct [:labels, :ticks, :bars]
end
