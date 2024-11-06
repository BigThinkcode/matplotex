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

  def sample_figure() do
    x = [1, 3, 7, 4, 2, 5, 6]
    y = [1, 3, 7, 4, 2, 5, 6]

    frame_width = 8
    frame_height = 6
    size = {frame_width, frame_height}
    margin = 0.1
    font_size = 0
    title_font_size = 0
    ticks = [1, 2, 3, 4, 5, 6, 7]

    x
    |> Matplotex.plot(y)
    |> Matplotex.figure(%{figsize: size, margin: margin})
    |> Matplotex.set_title("The Plot Title")
    |> Matplotex.set_xticks(ticks)
    |> Matplotex.set_yticks(ticks)
    |> Matplotex.set_xlabel("The X Label")
    |> Matplotex.set_ylabel("The Y Label")
    |> Matplotex.set_xlim({1, 7})
    |> Matplotex.set_ylim({1, 7})
    |> Matplotex.set_rc_params(
      x_tick_font_size: font_size,
      y_tick_font_size: font_size,
      title_font_size: title_font_size,
      x_label_font_size: font_size,
      y_label_font_size: font_size,
      title_font_size: title_font_size
    )
  end

  def bar() do
    x = [1, 3, 7, 4, 2, 5, 6]
    y = [1, 3, 7, 4, 2, 5, 6]

    frame_width = 8
    frame_height = 6
    size = {frame_width, frame_height}
    margin = 0.1
    font_size = 0
    title_font_size = 0
    ticks = [1, 2, 3, 4, 5, 6, 7]

    x
    |> Matplotex.bar(y)
    |> Matplotex.figure(%{figsize: size, margin: margin})
    |> Matplotex.set_title("The Plot Title")
    |> Matplotex.set_xticks(ticks)
    |> Matplotex.set_yticks(ticks)
    |> Matplotex.set_xlabel("The X Label")
    |> Matplotex.set_ylabel("The Y Label")
    |> Matplotex.set_xlim({1, 7})
    |> Matplotex.set_ylim({1, 7})
    |> Matplotex.set_rc_params(
      x_tick_font_size: font_size,
      y_tick_font_size: font_size,
      title_font_size: title_font_size,
      x_label_font_size: font_size,
      y_label_font_size: font_size,
      title_font_size: title_font_size
    )
  end

  def scatter() do
    x = [1, 3, 7, 4, 2, 5, 6]
    y = [1, 3, 7, 4, 2, 5, 6]

    frame_width = 8
    frame_height = 6
    size = {frame_width, frame_height}
    margin = 0.1
    font_size = 0
    title_font_size = 0
    ticks = [1, 2, 3, 4, 5, 6, 7]

    x
    |> Matplotex.scatter(y)
    |> Matplotex.figure(%{figsize: size, margin: margin})
    |> Matplotex.set_title("The Plot Title")
    |> Matplotex.set_xticks(ticks)
    |> Matplotex.set_yticks(ticks)
    |> Matplotex.set_xlabel("The X Label")
    |> Matplotex.set_ylabel("The Y Label")
    |> Matplotex.set_xlim({1, 7})
    |> Matplotex.set_ylim({1, 7})
    |> Matplotex.set_rc_params(
      x_tick_font_size: font_size,
      y_tick_font_size: font_size,
      title_font_size: title_font_size,
      x_label_font_size: font_size,
      y_label_font_size: font_size,
      title_font_size: title_font_size
    )
  end
end
