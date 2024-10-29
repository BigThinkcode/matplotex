defmodule Matplotex.Figure.Areal.ScatterTest do
  alias Matplotex.Figure.Areal.Scatter
  alias Matplotex.Figure
  use Matplotex.PlotCase

  setup do
    {:ok, %{figure: Matplotex.FrameHelpers.scatter()}}
  end
  describe "materialyze/1" do
    test "adds elements for dat",%{figure: figure} do
      assert %Figure{axes: %{data: {x,_y}, element: elements}} = Scatter.materialize(figure)
      assert Enum.count(elements, fn elem -> elem.type == "scatter.marker" end) == length(x)
    end
   end
end
