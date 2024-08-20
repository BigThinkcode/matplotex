defmodule Matplotex.BarChart do
  use Matplotex.Blueprint

  frame :bar_chart do
    field(:x_max)
    field(:y_max)
  end

  def new() do
    %__MODULE__{}
  end
end
