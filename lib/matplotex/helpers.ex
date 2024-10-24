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

  def lineplot_params() do
    %{
      "id" => "line-plot",
      "dataset" => [
        [1, 9, 8, 4, 6, 5, 3],
        [1, 6, 5, 3, 3, 8, 6]
      ],
      "x_labels" => ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
      "y_labels" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "width" => 700,
      "height" => 400,
      "x_margin" => 20,
      "y_margin" => 10,
      "x_label_offset" => 40,
      "y_label_offset" => 40,
      "y_scale" => 1,
      "x_scale" => 1,
      "color_palette" => ["red", "green"],
      "type" => "line_chart",
      "x_label" => "Days",
      "y_label" => "Count",
      "line_width" => 3
    }
  end

  def line_plot() do
    x = [1, 2, 3, 4, 6, 6, 7]
    y = [1, 3, 4, 4, 5, 6, 7]

    frame_width = 8
    frame_height = 6
    size = {frame_width, frame_height}
    margin = 0.05
    font_size = "16pt"
    title_font_size = "18pt"
    ticks = [1, 2, 3, 4, 5, 6, 7]

    x
    |> Matplotex.plot(y)
    |> Matplotex.figure(%{figsize: size, margin: margin})
    |> Matplotex.set_title("The Plot Title")
    |> Matplotex.set_xlabel("X Axis")
    |> Matplotex.set_ylabel("Y Axis")
    |> Matplotex.set_xticks(ticks)
    |> Matplotex.set_yticks(ticks)
    |> Matplotex.set_xlim({1,7})
    |> Matplotex.set_ylim({3,7})
    |> Matplotex.set_rc_params(
      x_tick_font_size: font_size,
      y_tick_font_size: font_size,
      title_font_size: title_font_size,
      x_label_font_size: font_size,
      y_label_font_size: font_size,
      title_font_size: title_font_size
    )
    |> Matplotex.show()
  end
end
