defmodule Matplotex.Figure.Areal.PlotOptionsTest do
  alias Matplotex.Figure
  alias Matplotex.Figure.Areal.PlotOptions
  use Matplotex.PlotCase

  setup do
    {:ok, %{figure: Matplotex.FrameHelpers.sample_figure()}}
  end

  describe "cast_options/1" do
    test "generate PlotOptions struct", %{} do
      assert %PlotOptions{} =
               PlotOptions.cast_options(
                 margin: 10,
                 x_limit: {0, 10},
                 y_limit: {-10, 10}
               )
    end
  end

  describe "set_options_in_figure/2" do
    test "update figure struct with plotting options", %{figure: figure} do
      options =
        PlotOptions.cast_options(
          margin: 10,
          x_limit: {0, 10},
          y_limit: {-10, 10}
        )

      assert %Figure{margin: 10, axes: %{limit: %{x: {0, 10}, y: {-10, 10}}}} =
               PlotOptions.set_options_in_figure(figure, options)
    end
  end
end
