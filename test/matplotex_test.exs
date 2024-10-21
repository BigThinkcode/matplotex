defmodule MatplotexTest do
  alias Matplotex.LinePlot
  alias Matplotex.Figure
  alias Matplotex.InputError
  use Matplotex.PlotCase

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
    assert figure.axes.data == {x, y}
    assert figure.axes.limit.x == {0, 8, 1}
    assert figure.axes.limit.y == {0, 8, 1}
    assert figure.axes.tick.x == 0..8 |> Enum.to_list()
    assert figure.axes.tick.y == 0..8 |> Enum.to_list()
  end

  test "raise error for invalid input" do
    assert_raise InputError, "Invalid x and y values for plot, x and y should be in list", fn ->
      Matplotex.plot("ser", "ser")
    end
  end

  test "adds xlabel to the figure ", %{figure: figure} do
    x_label = "Xlabel"
    figure = Matplotex.set_xlabel(figure, x_label)
    assert figure.axes.label.x.text == x_label
  end

  test "adds label with font", %{figure: figure} do
    label = "Label with font"
    font_size = 12
    color = "red"
    font_opts = [font_size: font_size, fill: color]
    figure = Matplotex.set_xlabel(figure, label, font_opts)
    assert figure.axes.label.x.text == label
    assert figure.axes.label.x.font.font_size == font_size
    assert figure.axes.label.x.font.fill == color
  end

  test "adds ylabel to the figure ", %{figure: figure} do
    y_label = "Ylabel"
    figure = Matplotex.set_ylabel(figure, y_label)
    assert figure.axes.label.y.text == y_label
  end

  test "adds title to the figure ", %{figure: figure} do
    title = "My Plot"
    figure = Matplotex.set_title(figure, title)
    assert figure.axes.title.text == title
  end

  test "adds title with font_opts to the figure ", %{figure: figure} do
    title = "My Plot"
    font_size = 12
    color = "red"
    font_opts = [font_size: font_size, fill: color]
    figure = Matplotex.set_title(figure, title, font_opts)
    assert figure.axes.title.text == title
    assert figure.axes.title.font.font_size == font_size
    assert figure.axes.title.font.fill == color
  end

  test "adds legend to the figure ", %{figure: figure} do
    labels = ["Data 1", "Data 2"]
    figure = Matplotex.legend(figure, %{labels: labels})
    assert figure.axes.legend.labels == labels
  end

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
      "line_style" => "-"
    }

    figure = Matplotex.set_rc_params(figure, rc_params)

    assert figure.rc_params.line_width == 2
    assert figure.rc_params.line_style == "-"
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
end
