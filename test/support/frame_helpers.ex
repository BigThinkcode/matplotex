defmodule Matplotex.FrameHelpers do
  def new(module, params), do: module.new(params)

  def set_content(module, chartset), do: module.set_content(chartset)

  def lineplot_params() do
    %{
      "id" => "line-plot",
      "dataset" => [
        [1, 9, 8, 4, 6, 5, 3],
        [1, 6, 5, 3, 3, 8, 6]
      ],
      "x_labels" => ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
      "width" => 700,
      "height" => 400,
      "x_margin" => 20,
      "y_margin" => 10,
      "y_scale" => 1,
      "x_scale" => 1,
      "color_palette" => ["654520", "6CBEC7"],
      "type" => "line_chart",
      "x_label" => "Days",
      "y_label" => "Count"
    }
  end
end
