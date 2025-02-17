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

      assert Enum.filter(elements, fn x -> x.type == "figure.bar" end) |> length() ==
               length(y)
    end

    test "bottom variable in opts makes stacked bar chart and it will stack the bars" do
      values1 = [2, 4, 3, 2]
      values2 = [1, 2, 1, 4]
      values3 = [3, 1, 2, 1]
      width = 0.3

      bar =
        Matplotex.bar(values1, width)
        |> Matplotex.bar(values2, width, bottom: [values1])
        |> Matplotex.bar(values3, width, bottom: [values2, values1])

      expected_elements_count = (values1 ++ values2 ++ values3) |> length()
      assert %Figure{axes: %{element: elements}} = Figure.materialize(bar)
      bar_elements = Enum.filter(elements, fn x -> x.type == "figure.bar" end)
      assert bar_elements |> length() == expected_elements_count
      assert Enum.all?(bar_elements, fn rect -> assert_valid_coords(rect) end)
    end
  end

  defp assert_valid_coords(rect) do
    rect.x > 0 and rect.y > 0 and rect.width > 0 and rect.height > 0
  end
end
