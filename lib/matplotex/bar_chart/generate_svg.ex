defmodule Matplotex.BarChart.GenerateSvg do
  alias Matplotex.Utils.Svg
  alias Matplotex.BarChart.Element
  alias Matplotex.Element.Stencil


  def generate(barset, svg) do
    {barset.element, svg}
    |> add_axis_lines()
    |> add_grid_lines()
    |> add_ticks()
    |> add_bars()
    |> then(fn {_, svg} -> Svg.wrap_with_frame(barset.size, svg) end)
  end

  defp add_bars({%Element{bars: bars} = element, svg}) when is_list(bars) do
    svg_bars =
      "#{for bar <- bars do
        Stencil.rect(bar)
      end}"

    {element, svg <> svg_bars}
  end

  defp add_bars(chart_svg), do: chart_svg

  # TODO: add default values for fill, stroke,

  defp add_axis_lines({%Element{axis: axis} = element, svg}) when is_list(axis) do
    axis_lines =
      "#{for axis_line <- axis do
        Stencil.line(axis_line)
      end}"

    {element, svg <> axis_lines}
  end

  defp add_axis_lines(chart_and_svg), do: chart_and_svg

  defp add_grid_lines({%Element{grid: grid} = element, svg}) when is_list(grid) do
    grid_lines =
      "#{for grid_line <- grid do
        Stencil.line(grid_line)
      end}"

    {element, svg <> grid_lines}
  end

  defp add_grid_lines(chart_svg), do: chart_svg

  defp add_ticks({%Element{ticks: ticks} = element, svg}) when is_list(ticks) do
    ticks =
      "
       #{for tick <- ticks do
        Stencil.tick(tick)
      end}
       "

    {element, svg <> ticks}
  end

  defp add_ticks(chart_svg), do: chart_svg


end
