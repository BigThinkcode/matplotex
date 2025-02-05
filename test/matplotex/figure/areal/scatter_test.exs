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
    test "adds point with specific color with color scheme" do
      x = [1, 3, 7, 4, 2, 5, 6]
      y = [1, 3, 7, 4, 2, 5, 6]
      colors = [1, 3, 7, 4, 2, 5, 6]

    assert %Figure{axes: %{element: elements}} =   x
    |> Matplotex.scatter(y, colors: colors)
    |> Matplotex.figure(%{figsize: size, margin: margin})
    |> Scatter.materialize()

    assert elements|>Enum.filter(fn elem -> elem.type == "point.color" end)|>length()
    end
  end

  describe "generate_ticks/2" do
    test "5 ticks will generate by default" do
      minmax = {1, 10}
      # inch

      {ticks, _lim} = Scatter.generate_ticks(minmax)
      # 5 ticks added with minimum value
      assert length(ticks) == 6
    end
  end
end
