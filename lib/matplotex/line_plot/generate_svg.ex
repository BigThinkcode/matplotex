defmodule Matplotex.LinePlot.GenerateSvg do
  alias Matplotex.Element.Stencil
  alias Matplotex.LinePlot.Element
  import Matplotex.Utils.Svg

  def generate(plotset, pre_svg) do
    {plotset.element, pre_svg}
    |> add_element(:axis)
    |> add_element(:grid)
    |> add_element(:lines)
    |> add_element(:labels)
    |> add_element(:ticks)
    |> then(fn {_, svg} -> wrap_with_frame(plotset.size, svg) end)
  end

  defp add_element({%Element{axis: axis} = element, svg}, :axis) do
    axis =
      "#{for ax <- axis do
        Stencil.line(ax)
      end}"

    {element, svg <> axis}
  end

  defp add_element({%Element{grid: grids} = element, svg}, :grid) do
    grid =
      "#{for grid <- grids do
        Stencil.line(grid)
      end}"

    {element, svg <> grid}
  end

  defp add_element({%Element{lines: lines} = element, svg}, :lines) do
    lines =
      "#{for line <- lines do
        Stencil.line(line)
      end}"

    {element, svg <> lines}
  end

  defp add_element({%Element{labels: labels} = element, svg}, :labels) do
    labels =
      "#{for label <- labels do
        Stencil.label(label)
      end}"

    {element, svg <> labels}
  end

  defp add_element({%Element{ticks: ticks} = element, svg}, :ticks) do
    ticks =
      "#{for tick <- ticks do
        Stencil.tick(tick)
      end}"

    {element, svg <> ticks}
  end
end
