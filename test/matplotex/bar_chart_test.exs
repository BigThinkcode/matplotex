defmodule Matplotex.BarChartTest do
  use Matplotex.PlotCase, async: true
  alias Matplotex.BarChart

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

    {:ok, %{params: input_params}}
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
  end
end
