defmodule Matplotex.FigureTest do
  use Matplotex.PlotCase
  @figure_fields [:id, :figsize, :axes, :element, :rows, :columns, :margin]
  test "contains all figure fields" do
    existing_fields =  %Matplotex.Figure{}|>Map.from_struct()|>Map.drop([:__struct__])|>Map.keys()|>Enum.sort()
    assert @figure_fields |>Enum.sort() == existing_fields
  end

  test "builds structs with default values for figsize, row, columns and margin" do
    figure = Matplotex.Figure.new(%{})
    assert figure.figsize == {10,6}
    assert figure.rows == 1
    assert figure.columns == 1
    assert figure.margin == 0.1
  end
end
