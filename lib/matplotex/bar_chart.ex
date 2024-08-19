defmodule Matplotex.BarChart do
  use Matplotex.Blueprint

  frame "bar_chart" do
    field(:y_max)
    field(:x_max)
  end

def new() do
  %__MODULE__{y_max: 100, x_max: 100}
end

end
