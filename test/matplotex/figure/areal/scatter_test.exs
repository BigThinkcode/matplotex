defmodule Matplotex.Figure.Areal.ScatterTest do
  alias Matplotex.Figure.Areal.Scatter
  alias Matplotex.Figure
  use Matplotex.PlotCase

  setup do
    {:ok, %{figure: Matplotex.FrameHelpers.scatter()}}
  end

  describe "materialyze/1" do
    test "adds elements for dat", %{figure: figure} do
      assert %Figure{axes: %{data: {x, _y}, element: elements}} = Scatter.materialize(figure)
      assert Enum.count(elements, fn elem -> elem.type == "plot.marker" end) == length(x)
    end
  end

  describe "generate_ticks/2" do
    test "generate ticks in a length of figure size" do
      minmax = {1, 10}
      # inch
      side = 10
      {ticks, _lim} = Scatter.generate_ticks(side, minmax)
      assert length(ticks) == side
    end
  end
end
