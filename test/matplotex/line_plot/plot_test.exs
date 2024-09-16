defmodule Matplotex.LinePlot.PlotTest do
  alias Matplotex.LinePlot.Element
  alias Matplotex.LinePlot.Content
  use Matplotex.PlotCase
  alias Matplotex.LinePlot.Plot

  alias Matplotex.LinePlot

  setup do
    params = %{
      "id" => "line-plot",
      "dataset" => [
        [1, 9, 8, 4, 6, 5, 3],
        [1, 6, 5, 3, 3, 8, 6]
      ],
      "show_x_axis" => true,
      "show_y_axis" => true,
      "show_v_grid" => true,
      "show_h_grid" => true,
      "x_labels" => ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
      "width" => 700,
      "height" => 400,
      "x_margin" => 20,
      "y_margin" => 10,
      "x_label_offset" => 20,
      "y_label_offset" => 20,
      "y_scale" => 1,
      "x_scale" => 1,
      "color_palette" => ["654520", "6CBEC7"],
      "type" => "line_chart",
      "x_label" => "Days",
      "y_label" => "Count"
    }
    {line_plot, content_params}  = Plot.new(LinePlot,params)
    line_plot_with_content = Plot.set_content({line_plot, content_params})
    {:ok, %{params: params, line_plot: line_plot, content_params: content_params, line_plot_with_content: line_plot_with_content}}
  end

  describe "new/2" do
    test "Returns Plot and content params", %{params: params} do
      assert {plot, content_params} = Plot.new(LinePlot, params)

      assert Map.keys(content_params)|> Enum.sort() == [
               :color_palette,
               :label_offset,
               :y_max,
               :x_max,
               :line_width,

      ]|> Enum.sort()

      assert plot.id == "line-plot"
    end
  end
  describe "set_content/1" do
    test "updates lineplot with content", %{line_plot: line_plot, content_params: content_params} do
        assert %LinePlot{content: %Content{} = content, valid: valid} = Plot.set_content({line_plot, content_params})
        assert valid
        assert !is_nil(content.color_palette)
    end
  end
  describe "add_elements" do
    test "fill all the element fields", %{line_plot_with_content: lineplot_with_content} do
      assert %LinePlot{errors: errors, dataset: dataset, element: %Element{lines: lines} = element, valid: valid} = Plot.add_elements(lineplot_with_content)
      elements = element|>Map.values()|>Enum.filter(fn element -> !is_nil(element) end)
      assert valid
      assert length(elements) == element|>Map.values()|>length()
      assert dataset|> List.flatten()|>length()  == lines|>length()
    end
  end
end
