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

end
