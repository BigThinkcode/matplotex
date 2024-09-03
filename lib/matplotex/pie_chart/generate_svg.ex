defmodule Matplotex.PieChart.GenerateSvg do
  alias Matplotex.PieChart.Legend
  alias Matplotex.PieChart
  alias Matplotex.Utils.Svg
  alias Matplotex.Element.Stencil
  alias Matplotex.PieChart.Element

  @spec generate(PieChart.t(), String.t()) :: String.t()
  def generate(chartset, pre_svg) do
    {chartset.element, pre_svg}
    |> add_element(:slices)
    |> add_element(:labels)
    |> add_element(:legends)
    |> then(fn {_, svg} -> Svg.wrap_with_frame(chartset.size, svg) end)
  end

  defp add_element({%Element{slices: slices} = element, svg}, :slices) do
    slices =
      "#{for slice <- slices do
        Stencil.slice(slice)
      end}"

    {element, svg <> slices}
  end

  defp add_element({%Element{labels: labels} = element, svg}, :labels) do
    labels =
      " #{for label <- labels do
        Stencil.label(label)
      end}
      "

    {element, svg <> labels}
  end

  defp add_element({%Element{legends: legends} = element, svg}, :legends) do
    legends =
      " #{for legend <- legends do
        legend = Legend.generate_label(legend)
        Stencil.legend(legend)
      end}
      "

    {element, svg <> legends}
  end

  defp add_element(element, _), do: element
end
