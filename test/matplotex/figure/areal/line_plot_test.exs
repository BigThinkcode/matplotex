defmodule Matplotex.Figure.Areal.LinePlotTest do
  alias Matplotex.Figure
  alias Matplotex.LinePlot
  use Matplotex.PlotCase

  setup do
    {:ok, %{figure: Matplotex.FrameHelpers.sample_figure()}}
  end

  describe "materialyze/1" do
    test "will materialize figure with lines", %{figure: figure} do
      assert %Figure{axes: %{element: elements}} = LinePlot.materialize(figure)
      [elem1 | _] = Enum.filter(elements, fn elem -> elem.type == "plot.line" end)
      assert elem1.fill == "blue"
      assert elem1.linestyle == "_"
    end
  end

  describe "create/4" do
    test "adds new dataset to the figure to create multiple lines" do
      x = [1, 2, 3, 4, 5]
      # Dataset 1
      y1 = [1, 4, 9, 16, 25]
      # Dataset 2
      y2 = [1, 3, 6, 10, 15]
      # Dataset 3
      y3 = [2, 5, 7, 12, 17]

      assert %Figure{axes: %LinePlot{element: element}} =
               x
               |> Matplotex.plot(y1,
                 color: "blue",
                 linestyle: "_",
                 marker: "o",
                 label: "Dataset 1"
               )
               |> Matplotex.plot(x, y2,
                 color: "red",
                 linestyle: "--",
                 marker: "^",
                 label: "Dataset 2"
               )
               |> Matplotex.plot(x, y3,
                 color: "green",
                 linestyle: "-.",
                 marker: "s",
                 label: "Dataset 3"
               )
               |> Matplotex.set_title("Title")
               |> Matplotex.set_xlabel("X-Axis")
               |> Matplotex.set_ylabel("Y-Axis")
               |> LinePlot.materialize()

      element = Enum.filter(element, fn elem -> elem.type == "plot.line" end)

      assert Enum.any?(element, fn line -> line.fill == "blue" && line.linestyle == "_" end)
      assert Enum.any?(element, fn line -> line.fill == "red" && line.linestyle == "--" end)
      assert Enum.any?(element, fn line -> line.fill == "green" && line.linestyle == "-." end)
    end
  end
end
