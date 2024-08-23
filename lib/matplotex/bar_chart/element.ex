defmodule Matplotex.BarChart.Element do
  @type t :: %__MODULE__{labels: list(), ticks: list(), bars: list(), grid: list(), axis: list()}
  defstruct [:labels, :ticks, :bars, :grid, :axis]
end
