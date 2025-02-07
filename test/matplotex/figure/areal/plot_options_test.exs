defmodule Matplotex.Figure.Areal.PlotOptionsTest do
  alias Matplotex.Figure
  use Matplotex.PlotCase

  setup do
    {:ok, %{figure: Matplotex.FrameHelpers.sample_figure()}}
  end

  describe "set_options_in_figure" do
    test "plot options should't allow some restricted keys", %{figure: figure} do
      figure =
        figure
        |> Matplotex.set_title("New title")
        |> Matplotex.plot([1, 2, 3, 4, 5], [1, 2, 3, 4, 5],
          x_lagel: "X",
          axes: nil,
          region_x: nil,
          region_y: nil,
          region_content: nil,
          region_title: nil,
          elements: nil
        )

      refute figure.axes.region_x == nil
      refute figure.axes.region_y == nil
      refute figure.axes.region_content == nil
      refute figure.axes.region_title == nil
      refute figure.axes.element == nil
      refute figure.axes == nil
    end
    test "updates cmap as a list by its name" do
    assert %Figure{axes: %{cmap: cmap}} =   [1, 2, 3, 4, 5, 6]
      |> Matplotex.plot([1, 2, 3, 4, 5],
        cmap: "viridis",
        colors: [3, 4, 5, 6, 7, 3, 2, 4]
      )
      assert is_list(cmap)
    end
  end
end
