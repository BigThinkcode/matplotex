defmodule MatplotexTest do
  alias Matplotex.Figure.Dataset
  alias Matplotex.InputError
  use Matplotex.PlotCase
  alias Matplotex.Figure

  setup do
    x = [1, 3, 7, 4, 2, 5, 6]
    y = [1, 3, 7, 4, 2, 5, 6]

    figure = Matplotex.plot(x, y)
    {:ok, %{figure: figure}}
  end

  test "plot can create a figure with axes by data and setup tick and limits" do
    x = [1, 3, 7, 4, 2, 5, 6]
    y = [1, 3, 7, 4, 2, 5, 6]

    assert figure = Matplotex.plot(x, y)
    assert figure.axes.dataset |> List.first() |> Map.get(:x) == x
    assert figure.axes.dataset |> List.first() |> Map.get(:y) == y
  end

  test "raise error for invalid input" do
    assert_raise InputError, "Invalid x and y values for plot, x and y should be in list", fn ->
      Matplotex.plot("ser", "ser")
    end
  end

  test "adds xlabel to the figure ", %{figure: figure} do
    x_label = "Xlabel"
    figure = Matplotex.set_xlabel(figure, x_label)
    assert figure.axes.label.x == x_label
  end

  test "adds ylabel to the figure ", %{figure: figure} do
    y_label = "Ylabel"
    figure = Matplotex.set_ylabel(figure, y_label)
    assert figure.axes.label.y == y_label
  end

  test "adds title to the figure ", %{figure: figure} do
    title = "My Plot"
    figure = Matplotex.set_title(figure, title)
    assert figure.axes.title == title
  end

  # test "adds legend to the figure ", %{figure: figure} do
  #   labels = ["Data 1", "Data 2"]
  #   figure = Matplotex.legend(figure, %{labels: labels})
  #   assert figure.axes.legend.labels == labels
  # end

  test "adds xlim to the figure ", %{figure: figure} do
    xlim = {1, 10}
    figure = Matplotex.set_xlim(figure, xlim)
    assert figure.axes.limit.x == xlim
  end

  test "adds ylim to the figure ", %{figure: figure} do
    ylim = {1, 10}
    figure = Matplotex.set_ylim(figure, ylim)
    assert figure.axes.limit.y == ylim
  end

  test "adds rc_params to the figure ", %{figure: figure} do
    rc_params = %{
      "x_tick_font_size" => 12,
      "y_tick_font_size" => 16,
      "x_label_font_size" => 14,
      "y_label_font_size" => 10,
      "line_width" => 2,
      "line_style" => "_"
    }

    figure = Matplotex.set_rc_params(figure, rc_params)

    assert figure.rc_params.line_width == 2
    assert figure.rc_params.line_style == "_"
    assert figure.rc_params.x_tick_font_size == 12
    assert figure.rc_params.y_tick_font_size == 16
  end

  test "figure updates the params of the figure", %{figure: figure} do
    size = {5, 4}
    figure = Matplotex.figure(figure, %{figsize: size})
    assert figure.figsize == size
  end

  test "raise error if invalid params passed", %{figure: figure} do
    assert_raise Matplotex.InputError, "Invalid keys", fn ->
      Matplotex.figure(figure, %{invalid: "im not valid"})
    end
  end

  test "svg string with border lines", %{figure: figure} do
    frame_width = 8
    frame_height = 6
    size = {frame_width, frame_height}
    margin = 0.1
    font_size = 0
    title_font_size = 0
    ticks = [1, 2, 3, 4, 5, 6, 7]

    figure_mater =
      figure
      |> Matplotex.figure(%{figsize: size, margin: margin})
      |> Matplotex.set_title("The Plot Title")
      |> Matplotex.set_xlabel("X Axis")
      |> Matplotex.set_ylabel("Y Axis")
      |> Matplotex.set_xticks(ticks)
      |> Matplotex.set_yticks(ticks)
      |> Matplotex.set_rc_params(
        x_tick_font_size: font_size,
        y_tick_font_size: font_size,
        title_font_size: title_font_size,
        x_label_font_size: font_size,
        y_label_font_size: font_size,
        title_font_size: title_font_size
      )

    assert Matplotex.show(figure_mater) |> is_binary()
  end

  describe "set_figure_size" do
    test "updates the frame size based on margin also", %{figure: figure} do
      fwidth = 10
      fheight = 8

      assert %Figure{margin: margin, axes: %{size: {width, height}}} =
               Matplotex.set_figure_size(figure, {fwidth, fheight})

      assert width == fwidth - fwidth * margin * 2
      assert height == fheight - fheight * margin * 2
    end
  end

  describe "set_margin" do
    test "updates the frame size according to margin", %{figure: figure} do
      margin = 0.01

      assert %Figure{figsize: {fwidth, fheight}, axes: %{size: {width, height}}} =
               Matplotex.set_margin(figure, margin)

      assert width == fwidth - fwidth * margin * 2
      assert height == fheight - fheight * margin * 2
    end
  end

  describe "with plot options" do
    test "updates the values according to the plot options in line_plot" do
      x = [1, 3, 7, 4, 2, 5, 6]
      y = [1, 3, 7, 4, 2, 5, 6]

      options = [
        x_label: "X Axis",
        y_label: "Y Axis",
        title: "The Plot Title",
        x_ticks: [1, 2, 3, 4, 5, 6, 7],
        y_ticks: [1, 2, 3, 4, 5, 6, 7],
        x_tick_font_size: 12,
        y_tick_font_size: 16,
        title_font_size: 14,
        x_label_font_size: 10,
        y_label_font_size: 10,
        title_font_size: 14,
        line_width: 2,
        figsize: {10, 10},
        x_limit: [1, 7],
        y_limit: [1, 7],
        line_style: "_"
      ]

      figure = Matplotex.plot(x, y, options)

      assert figure.axes.label.x == "X Axis"
      assert figure.axes.label.y == "Y Axis"
      assert figure.axes.title == "The Plot Title"
      assert figure.axes.dataset |> List.first() |> Map.get(:x) == x
      assert figure.axes.dataset |> List.first() |> Map.get(:y) == y
      assert figure.axes.limit.x == [1, 7]
      assert figure.axes.limit.y == [1, 7]
      assert figure.rc_params.line_width == 2
      assert figure.figsize == {10, 10}
      assert figure.rc_params.line_style == "_"
      assert figure.rc_params.x_tick_font.font_size == 12
      assert figure.rc_params.y_tick_font.font_size == 16
      assert figure.rc_params.title_font.font_size == 14
      assert figure.rc_params.x_label_font.font_size == 10
      assert figure.rc_params.y_label_font.font_size == 10
    end
  end

  test "updates the values according to the plot options in bar_chart" do
    values = [1, 3, 7, 4, 2, 5, 6]
    width = 0.22

    options = [
      x_label: "X Axis",
      y_label: "Y Axis",
      title: "The Plot Title",
      x_ticks: [1, 2, 3, 4, 5, 6, 7],
      y_ticks: [1, 2, 3, 4, 5, 6, 7],
      x_tick_font_size: 12,
      y_tick_font_size: 16,
      title_font_size: 14,
      x_label_font_size: 10,
      y_label_font_size: 10,
      title_font_size: 14,
      line_width: 2,
      figsize: {10, 10},
      x_limit: [1, 7],
      y_limit: [1, 7],
      line_style: "_"
    ]

    figure = Matplotex.bar(values, width, options)

    assert figure.axes.label.x == "X Axis"
    assert figure.axes.label.y == "Y Axis"
    assert figure.axes.title == "The Plot Title"
    assert figure.axes.dataset |> List.first() |> Map.get(:y) == values
    assert figure.axes.limit.x == [1, 7]
    assert figure.axes.limit.y == [1, 7]
    assert figure.rc_params.line_width == 2
    assert figure.figsize == {10, 10}
    assert figure.rc_params.line_style == "_"
    assert figure.rc_params.x_tick_font.font_size == 12
    assert figure.rc_params.y_tick_font.font_size == 16
    assert figure.rc_params.title_font.font_size == 14
    assert figure.rc_params.x_label_font.font_size == 10
    assert figure.rc_params.y_label_font.font_size == 10
  end

  test "updates the values according to the plot options in scatter plot" do
    x = [1, 3, 7, 4, 2, 5, 6]
    y = [1, 3, 7, 4, 2, 5, 6]

    options = [
      x_label: "X Axis",
      y_label: "Y Axis",
      title: "The Plot Title",
      x_ticks: [1, 2, 3, 4, 5, 6, 7],
      y_ticks: [1, 2, 3, 4, 5, 6, 7],
      x_tick_font_size: 12,
      y_tick_font_size: 16,
      title_font_size: 14,
      x_label_font_size: 10,
      y_label_font_size: 10,
      title_font_size: 14,
      line_width: 2,
      figsize: {10, 10},
      x_limit: [1, 7],
      y_limit: [1, 7],
      line_style: "_"
    ]

    figure = Matplotex.scatter(x, y, options)

    assert figure.axes.label.x == "X Axis"
    assert figure.axes.label.y == "Y Axis"
    assert figure.axes.title == "The Plot Title"
    assert figure.axes.dataset |> List.first() |> Map.get(:x) == x
    assert figure.axes.dataset |> List.first() |> Map.get(:y) == y
    assert figure.axes.limit.x == [1, 7]
    assert figure.axes.limit.y == [1, 7]
    assert figure.rc_params.line_width == 2
    assert figure.figsize == {10, 10}
    assert figure.rc_params.line_style == "_"
    assert figure.rc_params.x_tick_font.font_size == 12
    assert figure.rc_params.y_tick_font.font_size == 16
    assert figure.rc_params.title_font.font_size == 14
    assert figure.rc_params.x_label_font.font_size == 10
    assert figure.rc_params.y_label_font.font_size == 10
  end

  describe "hist" do
    test "creates a figure for histogram" do
      values =
        Nx.Random.key(12) |> Nx.Random.normal(0, 1, shape: {1000}) |> elem(0) |> Nx.to_list()

      bins = 30
      figure = Matplotex.hist(values, bins, x_label: "Value", y_label: "Frequency")
      assert %Dataset{x: x, y: y} = hd(figure.axes.dataset)
      assert length(x) == bins
      assert length(y) == bins
      assert figure.axes.label.x == "Value"
      assert figure.axes.label.y == "Frequency"
    end
  end
end
