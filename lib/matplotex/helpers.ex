defmodule Matplotex.Helpers do
  def copy(term) do
    text =
      if is_binary(term) do
        term
      else
        inspect(term, limit: :infinity, pretty: true)
      end

    port = Port.open({:spawn, "pbcopy"}, [])
    true = Port.command(port, text)
    true = Port.close(port)

    :ok
  end

  def barchart_params() do
    %{
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
      "color_palette" => "#5cf",
      "width" => 700,
      "x_margin" => 15,
      "y_margin" => 15,
      "height" => 300,
      "y_scale" => 20,
      "y_label_suffix" => "K",
      "y_label_offset" => 40,
      "x_label_offset" => 20
    }
  end

  def pie_chart_params() do
    %{
      "id" => "chart-container",
      "dataset" => [280, 45, 133, 152, 278, 221, 56],
      "labels" => ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
      "color_palette" => ["#f66", "pink", "orange", "gray", "#fcc", "green", "#0f0"],
      "width" => 700,
      "height" => 400,
      "margin" => 15,
      "legends" => true
    }
  end
end
