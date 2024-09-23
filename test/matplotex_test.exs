defmodule MatplotexTest do
  use Matplotex.PlotCase

  test "plot can create a figure with axes by data" do
    x = [1,3,7,4,2,5,6]
    y = [1,3,7,4,2,5,6]

   assert figure =  Matplotex.plot(x,y)
   assert figure.axes.data == {x,y}
  end
end
