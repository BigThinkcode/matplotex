defmodule Matplotex.BarChartTest do
  use Matplotex.PlotCase, async: true
  alias Matplotex.BarChart
  alias Matplotex.BarChart.Content
  alias Matplotex.BarChart.Element

  setup do
    input_params = %{
      "dataset" => [44, 56, 67, 67, 89, 14, 57, 33, 59, 67, 90, 34],
      "x_labels" => [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ],
      "color_palette" => ["#5cf"],
      "width" => 700,
      "x_margin" => 15,
      "y_margin" => 15,
      "height" => 300,
      "y_scale" => 20,
      "y_label_suffix" => "K",
      "y_label_offset" => 40,
      "x_label_offset" => 20
    }

    {new_barchart, content_params} = BarChart.new(input_params)
    barchart_with_content = BarChart.set_content({new_barchart, content_params})

    {:ok,
     %{
       params: input_params,
       new_barchart: new_barchart,
       content_params: content_params,
       barchart_with_content: barchart_with_content
     }}
  end

  describe "new/1" do
    test "create a Chart struct for valid data", %{params: params} do
      assert {%BarChart{size: %{width: width, height: height}}, _} = BarChart.new(params)
      assert width == Map.get(params, "width")
      assert height == Map.get(params, "height")
    end

    test "raise error for invalid input", %{params: params} do
      invalid_params = Map.replace(params, "height", "nonumber")
      assert_raise(Matplotex.InputError, fn -> BarChart.new(invalid_params) end)
    end

    test "raise error for invalid dataset", %{params: %{"dataset" => dataset} = params} do
      invalid_dataset = List.insert_at(dataset, 0, "nonumber")
      invalid_params = Map.replace(params, "dataset", invalid_dataset)

      assert_raise(
        Matplotex.InputError,
        "Invalid input [{\"dataset\", [\"nonumber\", 44, 56, 67, 67, 89, 14, 57, 33, 59, 67, 90, 34]}]",
        fn -> BarChart.new(invalid_params) end
      )
    end
  end

  describe "set_content/1" do
    test "should return a barchart with content", %{
      params: %{"width" => width, "height" => height},
      new_barchart: new_barchart,
      content_params: content_params
    } do
      assert %BarChart{content: %Content{width: content_width, height: content_height}} =
               BarChart.set_content({new_barchart, content_params})

      assert content_width < width
      assert content_height < height
    end
  end

  describe "add_elements/1" do
    test "sholuld return a barchart with elements", %{
      barchart_with_content: barchart_with_content
    } do
      assert %BarChart{element: %Element{bars: bars, ticks: ticks, labels: labels}} =
               BarChart.add_elements(barchart_with_content)

      assert length(bars) > 0
      assert length(ticks) > 0
      assert length(labels) > 0
    end
  end
end
