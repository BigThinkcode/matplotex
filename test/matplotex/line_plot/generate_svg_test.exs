defmodule Matplotex.LinePlot.GenerateSvgTest do
  alias Matplotex.FrameHelpers
  alias Matplotex.Element.Stencil
  alias Matplotex.LinePlot.GenerateSvg
  alias Matplotex.LinePlot.Element
  alias Matplotex.LinePlot.Plot
  alias Matplotex.LinePlot
  use Matplotex.PlotCase

  setup do
    params = FrameHelpers.lineplot_params()

    line_plot =
      LinePlot
      |> Plot.new(params)
      |> Plot.set_content()
      |> Plot.add_elements()

    {:ok, %{line_plot: line_plot}}
  end

  describe "generate/2" do
    test "will add axis line elements", %{
      line_plot: %LinePlot{element: %Element{axis: axis}} = lineplot
    } do
      axis = hd(axis)
      assert GenerateSvg.generate(lineplot, "") =~ Stencil.line(axis)
    end

    test "will add grid lines", %{line_plot: %LinePlot{element: %Element{grid: grids}} = lineplot} do
      grid = hd(grids)
      assert GenerateSvg.generate(lineplot, "") =~ Stencil.line(grid)
    end

    test "will add plot lines", %{
      line_plot: %LinePlot{element: %Element{lines: lines}} = lineplot
    } do
      line = hd(lines)
      assert GenerateSvg.generate(lineplot, "") =~ Stencil.line(line)
    end

    test "will add labels", %{line_plot: %LinePlot{element: %Element{labels: labels}} = lineplot} do
      label = hd(labels)
      assert GenerateSvg.generate(lineplot, "") =~ Stencil.label(label)
    end

    test "will add ticks", %{line_plot: %LinePlot{element: %Element{ticks: ticks}} = lineplot} do
      tick = hd(ticks)
      assert GenerateSvg.generate(lineplot, "") =~ Stencil.tick(tick)
    end
  end
end
