defmodule Matplotex.Figure.Radial.PieTest do
  alias Matplotex.Figure.Radial.Pie
  alias Matplotex.Figure
  use Matplotex.PlotCase


  describe "create/3" do
    test "creates a pie with dataset" do
      sizes = [25, 35, 20, 20]  # Percentages for each slice
      labels = ["Category A", "Category B", "Category C", "Category D"]  # Labels for each slice
      colors = ["lightblue", "lightgreen", "orange", "pink"]  # Colors for the slices
     assert %Figure{axes: %{dataset: dataset}} = Pie.create(%Figure{axes: %Pie{}}, sizes, labels: labels, colors: colors)
     assert dataset.sizes == sizes
    end
  end

  describe "materialize/1" do
    test "materialized figure contains elements for slices" do
      sizes = [25, 35, 20, 20]  # Percentages for each slice
      labels = ["Category A", "Category B", "Category C", "Category D"]  # Labels for each slice
      colors = ["lightblue", "lightgreen", "orange", "pink"]  # Colors for the slices
      figure = Pie.create(%Figure{axes: %Pie{}}, sizes, labels: labels, colors: colors)
      assert %Figure{axes: %{element: element}} =  Pie.materialize(figure)
      assert  Enum.filter(element, fn elem -> elem.type == "pie.slice" end)|>length() == length(sizes)
    end
  end
end
