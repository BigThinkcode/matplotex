defmodule MatplotexTest do
  use Matplotex.PlotCase
  setup do
    x = [1,3,7,4,2,5,6]
    y = [1,3,7,4,2,5,6]

    figure =  Matplotex.plot(x,y)
    {:ok, %{figure: figure}}

  end

  test "plot can create a figure with axes by data" do
    x = [1,3,7,4,2,5,6]
    y = [1,3,7,4,2,5,6]

   assert figure =  Matplotex.plot(x,y)
   assert figure.axes.data == {x,y}
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
      font_opts = [font_size: font_size, color: color]
      figure = Matplotex.set_xlabel(figure, label, font_opts)
      assert figure.axes.label.x.text == label
      assert figure.axes.label.x.font.font_size == font_size
      assert figure.axes.label.x.font.color == color

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
      font_opts = [font_size: font_size, color: color]
      figure = Matplotex.set_title(figure, title, font_opts)
      assert figure.axes.title.text == title
      assert figure.axes.title.font.font_size == font_size
      assert figure.axes.title.font.color == color
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

end
