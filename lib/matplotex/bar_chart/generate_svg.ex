defmodule Matplotex.BarChart.GenerateSvg do
  alias Matplotex.BarChart.Element
  import Matplotex.Element.Stencil
  def generate(barset, svg) do
    {barset.element, svg}
    |>add_axis_lines()
    |>add_grid_lines()
    |>add_ticks()
    |>add_bars()
    |>then(fn {_, svg} -> wrap_with_frame({barset, svg}) end)

end

  defp add_bars({%Element{bars: bars}=element, svg}) when is_list(bars) do
    svg_bars = "#{for bar <- bars do
      rect(bar)
     end }"
    {element, svg <> svg_bars}
  end

  defp add_bars(chart_svg), do: chart_svg

  # TODO: add default values for fill, stroke,

  defp add_axis_lines({%Element{axis: axis}= element, svg}) when is_list(axis) do
    axis_lines =
      "#{for axis_line <- axis do
     line(axis_line)
     end }"

    {element, svg <> axis_lines}
  end
  defp add_axis_lines(chart_and_svg), do: chart_and_svg

  defp add_grid_lines({%Element{grid: grid} =element, svg}) when is_list(grid) do
    grid_lines =
      "#{for grid_line <- grid do
       line(grid_line)
       end }"


    {element, svg <> grid_lines}
  end
  defp add_grid_lines(chart_svg), do: chart_svg
  defp add_ticks({%Element{ticks: ticks} =element, svg}) when is_list(ticks) do
    ticks =
      "
       #{for tick <- ticks do
       tick(tick)
        end }
       "
       {element, svg <> ticks}
  end
  defp add_ticks(chart_svg), do: chart_svg

    defp wrap_with_frame({%{size: %{width: width, height: height}},svg}) do
    ~s(<svg width="#{width}"
    height="#{height}"
    version="1.1"
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    style="top: 0px;
    left: 0px;
    position: absolute;">
    <g>
    #{svg}
    </g>
    </svg>
    )

  end
end
