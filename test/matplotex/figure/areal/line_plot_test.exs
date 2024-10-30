defmodule Matplotex.Figure.Areal.LinePlotTest do
  alias Matplotex.Figure
  alias Matplotex.LinePlot
  use Matplotex.PlotCase

  setup do
    {:ok, %{figure: Matplotex.FrameHelpers.sample_figure()}}
  end

  describe "materialyze/1" do
    test "will materialize figure with lines", %{figure: figure} do
      assert %Figure{axes: %{element: elements}} = LinePlot.materialize(figure)
      IO.inspect(elements)
      [elem1|_] = Enum.filter(elements, fn elem -> elem.type == "plot.line" end)
      assert elem1.fill == "blue"
      assert elem1.linestyle == "-"

    end
  end
end
