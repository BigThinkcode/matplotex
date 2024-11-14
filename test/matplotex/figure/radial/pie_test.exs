defmodule Matplotex.Figure.Radial.PieTest do
  alias Matplotex.Figure.Radial.Pie
  alias Matplotex.Figure
  use Matplotex.PlotCase

  describe "create/3" do
    test "creates a pie with dataset" do
      # Percentages for each slice
      sizes = [25, 35, 20, 20]
      # Labels for each slice
      labels = ["Category A", "Category B", "Category C", "Category D"]
      # Colors for the slices
      colors = ["lightblue", "lightgreen", "orange", "pink"]

      assert %Figure{axes: %{dataset: dataset}} =
               Pie.create(%Figure{axes: %Pie{}}, sizes, labels: labels, colors: colors)

      assert dataset.sizes == sizes
    end
  end

  describe "materialize/1" do
    test "materialized figure contains elements for slices" do
      # Percentages for each slice
      sizes = [25, 35, 20, 20]
      # Labels for each slice
      labels = ["Category A", "Category B", "Category C", "Category D"]
      # Colors for the slices
      colors = ["lightblue", "lightgreen", "orange", "pink"]
      figure = Pie.create(%Figure{axes: %Pie{}}, sizes, labels: labels, colors: colors)
      assert %Figure{axes: %{element: element}} = Pie.materialize(figure)

      assert Enum.filter(element, fn elem -> elem.type == "pie.slice" end) |> length() ==
               length(sizes)
    end
  end
end
