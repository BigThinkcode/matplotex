defmodule Matplotex.Figure.Areal.BarChartTest do
  alias Matplotex.Figure.Areal.BarChart
  alias Matplotex.Figure
  alias Matplotex.PlotCase
  use PlotCase

  setup do
    {:ok, %{figure: Matplotex.FrameHelpers.bar()}}
  end

  describe "materialyze/1" do
    test "adds figure with rectangles for bars", %{
      figure: %Figure{axes: %{data: {_x, y}}} = figure
    } do
      assert %Figure{axes: %{element: elements}} =
               BarChart.materialized_by_region(figure) |> BarChart.materialize()

      assert assert Enum.filter(elements, fn x -> x.type == "figure.bar" end) |> length() ==
                      length(y)
    end
  end
end
