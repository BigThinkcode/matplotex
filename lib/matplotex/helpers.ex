defmodule Matplotex.Helpers do
  def copy(term) do
    text =
      if is_binary(term) do
        term
      else
        inspect(term, limit: :infinity, pretty: true)
      end

    port =
      if :os.type() == {:unix, :linux},
        do: Port.open({:spawn, "xclip -selection clipboard"}, [:binary]),
        else: Port.open({:spawn, "pbcopy"}, [])

    true = Port.command(port, text)
    true = Port.close(port)

    :ok
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

    frame_width = 10
    frame_height = 10
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
    |> Matplotex.set_xlim({4, 7})
    |> Matplotex.set_ylim({4, 7})
    # TODO: Setting limits are not taking the proper xy values
    |> Matplotex.set_rc_params(
      x_tick_font_size: font_size,
      y_tick_font_size: font_size,
      title_font_size: title_font_size,
      x_label_font_size: font_size,
      y_label_font_size: font_size,
      title_font_size: title_font_size
    )
    |> Matplotex.show()
    |> copy()
  end

  def line_plotc() do
    x = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    y = [1, 3, 4, 4, 5, 6, 7]

    frame_width = 8
    frame_height = 6
    size = {frame_width, frame_height}
    margin = 0.05
    font_size = "16pt"
    title_font_size = "18pt"
    ticks = [1, 2, 3, 4, 5, 6, 7]
    xticks = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    x
    |> Matplotex.plot(y)
    |> Matplotex.figure(%{figsize: size, margin: margin})
    |> Matplotex.set_title("Sample plot")
    |> Matplotex.set_xlabel("X Axis")
    |> Matplotex.set_ylabel("Y Axis")
    |> Matplotex.set_xticks(xticks)
    |> Matplotex.set_yticks(ticks)
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
    |> Matplotex.show()
    |> copy()
  end

  # def bar() do
  #   values = [2, 1, 3, 7, 3, 5, 4]
  #   categories = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

  #   frame_width = 8
  #   frame_height = 6
  #   size = {frame_width, frame_height}
  #   margin = 0.05
  #   font_size = 0
  #   title_font_size = 0
  #   yticks = [0, 1, 2, 3, 4, 5, 6, 7]

  #   categories
  #   |> Matplotex.bar(values)
  #   |> Matplotex.figure(%{figsize: size, margin: margin})
  #   |> Matplotex.set_title("Sample barchart")
  #   |> Matplotex.set_xticks(categories)
  #   |> Matplotex.set_yticks(yticks)
  #   |> Matplotex.set_xlabel("Category")
  #   |> Matplotex.set_ylabel("Values")
  #   |> Matplotex.set_xlim({1, 7})
  #   |> Matplotex.set_ylim({0, 7})
  #   |> Matplotex.hide_v_grid()
  #   |> Matplotex.set_rc_params(
  #     x_tick_font_size: font_size,
  #     y_tick_font_size: font_size,
  #     title_font_size: title_font_size,
  #     x_label_font_size: font_size,
  #     y_label_font_size: font_size,
  #     title_font_size: title_font_size,
  #     y_padding: 0
  #   )
  #   |> Matplotex.show()
  #   |> copy()
  # end

  def scatter() do
    # x = [10, 20, 3, 4, 6, 6, 7]
    # y = [1, 3, 4, 4, 5, 6, 7]
    x = [0, 10, 20]
    y = [0, 10, 20]
    frame_width = 10
    frame_height = 10
    size = {frame_width, frame_height}
    margin = 0.05
    font_size = "16pt"
    title_font_size = "18pt"
    ticks = [0, 10, 20]

    x
    |> Matplotex.scatter(y)
    |> Matplotex.figure(%{figsize: size, margin: margin})
    |> Matplotex.set_title("Sample Scatter plot")
    |> Matplotex.set_xlabel("X Axis")
    |> Matplotex.set_ylabel("Y Axis")
    |> Matplotex.set_xticks(ticks)
    |> Matplotex.set_yticks(ticks)
    |> Matplotex.set_xlim({0, 20})
    |> Matplotex.set_ylim({0, 20})
    # TODO: Setting limits are not taking the proper xy values
    |> Matplotex.set_rc_params(
      x_tick_font_size: font_size,
      y_tick_font_size: font_size,
      title_font_size: title_font_size,
      x_label_font_size: font_size,
      y_label_font_size: font_size,
      title_font_size: title_font_size
    )
    |> Matplotex.show()
    |> copy()
  end

  def multiline_plot() do
    x = [1, 2, 3, 4, 5]
    # Dataset 1
    y1 = [1, 4, 9, 16, 25]
    # Dataset 2
    y2 = [1, 3, 6, 10, 15]
    # Dataset 3
    y3 = [2, 5, 7, 12, 17]

    x
    |> Matplotex.plot(y1, color: "blue", linestyle: "_", marker: "o", label: "Dataset 1")
    |> Matplotex.plot(x, y2, color: "red", linestyle: "--", marker: "^", label: "Dataset 2")
    |> Matplotex.plot(x, y3, color: "green", linestyle: "-.", marker: "s", label: "Dataset 3")
    |> Matplotex.set_title("Title")
    |> Matplotex.set_xlabel("X-Axis")
    |> Matplotex.set_ylabel("Y-Axis")
    |> Matplotex.show()
    |> copy()
  end

  def multi_bar() do
    categories = ["apple", "banana", "fig", "avocado"]
    values1 = [22, 33, 28, 34]
    values2 = [53, 63, 59, 60]
    width = 0.22

    Matplotex.bar(width, values1, width, label: "Dataset1", color: "#255199")
    |> Matplotex.bar(-width, values2, width, label: "Dataset2", color: "orange")
    |> Matplotex.set_xticks(categories)
    |> Matplotex.figure(%{figsize: {10, 10}, margin: 0.05})
    |> Matplotex.set_title("Bar chart")
    |> Matplotex.set_xlabel("X-axis")
    |> Matplotex.set_ylabel("Y-Axis")
    |> Matplotex.hide_v_grid()
    |> Matplotex.set_rc_params(y_tick_flate: -0.6)
    |> Matplotex.set_ylim({0, 70})
    |> Matplotex.show()
    |> copy()
  end

  def multiline_scatter() do
    x = [1, 2, 3, 4, 5]
    # Dataset 1
    y1 = [20, 5, 12, 16, 25]
    # Dataset 2
    y2 = [10, 1, 6, 10, 15]
    # Dataset 3
    y3 = [17, 5, 8, 12, 17]

    x
    |> Matplotex.scatter(y1, color: "blue", linestyle: "_", marker: "o", label: "Dataset 1")
    |> Matplotex.scatter(x, y2, color: "red", linestyle: "--", marker: "^", label: "Dataset 2")
    |> Matplotex.scatter(x, y3, color: "green", linestyle: "-.", marker: "s", label: "Dataset 3")
    |> Matplotex.figure(%{figsize: {3, 3}, margin: 0.05})
    |> Matplotex.set_title("Title")
    |> Matplotex.set_xlabel("X-Axis")
    |> Matplotex.set_ylabel("Y-Axis")
    |> Matplotex.show()
    |> copy()
  end

  def pie() do
    # Percentages for each slice
    sizes = [25, 35, 20, 20]
    # Labels for each slice
    labels = ["A", "B", "C", "D"]
    # Colors for the slices
    colors = ["lightblue", "lightgreen", "orange", "pink"]

    sizes
    |> Matplotex.pie(colors: colors, labels: labels)
    |> Matplotex.set_title("Pie chart")
    |> Matplotex.figure(%{figsize: {3.5, 2.5}, margin: 0.05})
    |> Matplotex.show()
    |> copy()
  end

  def photon_scatter() do
    {density, energy} =
      "samples/photon.csv"
      |> Path.expand()
      |> File.stream!()
      |> CSV.decode!()
      |> Stream.drop(1)
      |> Stream.map(fn [density, energy, _continent, _emission, _, _] ->
        {String.to_float(density), String.to_float(energy)}
      end)
      |> Enum.unzip()

    Matplotex.scatter(density, energy, color: "#FBD1A2", marker: "o", label: "Photo energy")
    |> Matplotex.figure(%{figsize: {10, 4}, margin: 0.05})
    |> Matplotex.set_title("Photon density and photon energy")
    |> Matplotex.set_xlabel("Photon density")
    |> Matplotex.set_ylabel("Photon energy")
    |> Matplotex.show()
    |> copy()
  end

  def emission_pie() do
    categories = ["2008", "2009", "2010", "2011"]
    values = [18.48923375, 17.1923791, 17.48479218, 17.02021634]

    colors = ["#76b5c5", "#DEDEDE", "#FBD1A2", "#6195B4"]

    values
    |> Matplotex.pie(colors: colors, labels: categories)
    |> Matplotex.set_title("Asias Emission distribution(2008-2011)")
    |> Matplotex.set_rc_params(%{line_width: 1})
    |> Matplotex.figure(%{figsize: {10, 4}, margin: 0.15})
    |> Matplotex.show()
    |> copy()
  end
end
