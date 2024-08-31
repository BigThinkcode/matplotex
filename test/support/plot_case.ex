defmodule Matplotex.PlotCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Matplotex.Blueprint.Label
      alias Matplotex.Blueprint.Line
    end
  end
end
