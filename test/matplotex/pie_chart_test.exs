defmodule Matplotex.PieChartTest do
  alias Matplotex.PieChart.Element
  alias Matplotex.PieChart.Content
  use Matplotex.PlotCase, async: true
  alias Matplotex.PieChart

  setup do
    params = %{
      "id" => "chart-container",
      "dataset" => [280, 45, 133, 152, 278, 221, 56],
      "labels" => ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
      "color_palette" => ["#f66", "pink", "orange", "gray", "#fcc", "green", "#0f0"],
      "width" => 600,
      "height" => 400,
      "margin" => 15,
      "legends" => true
    }

    {pie_chart, content_params} = PieChart.new(params)
    chartset_with_content = PieChart.set_content({pie_chart, content_params})
    chartset_with_element = PieChart.add_elements(chartset_with_content)

    {:ok,
     %{
       params: params,
       content_params: content_params,
       chartset: pie_chart,
       chartset_with_content: chartset_with_content,
       chartset_with_elements: chartset_with_element
     }}
  end

  describe "new/1" do
    test "return pie_chart set and content params", %{params: params} do
      assert {pie_chart, content_params} = PieChart.new(params)
      assert pie_chart.id == Map.get(params, "id")
      assert content_params.legends
    end
  end

  describe "set_content/1" do
    test "will return a piechart with content", %{
      content_params: content_params,
      chartset: chartset
    } do
      assert %PieChart{content: %Content{}} = PieChart.set_content({chartset, content_params})
    end
  end

  describe "add_elements/1" do
    test "will return a chartset with elements", %{chartset_with_content: chartset} do
      assert %PieChart{element: %Element{} = element} = PieChart.add_elements(chartset)
    end
  end

  describe "generate_svg/1" do
    test "will generate svg by a chartset with valid elements", %{
      chartset_with_elements: chartset
    } do
      svg = PieChart.generate_svg(chartset)
      IO.puts(svg)
    end
  end
end
