defmodule Matplotex.PlotCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Matplotex.BarChart.Bar
      alias Matplotex.Blueprint.Label
      alias Matplotex.Blueprint.Line
      alias Matplotex.Blueprint.Chart
    end
  end
end
