defmodule Matplotex.LinePlot.PlotterTest do
  alias Matplotex.LinePlot
  alias Matplotex.LinePlot.Plotter
  use Matplotex.PlotCase

  describe "new" do
    test "will return a plot struct with data x and y" do
      x = [1,3,7,4,2,5,6]
      y = [1,3,7,4,2,5,6]

     assert %LinePlot{data: data} =  Plotter.new(LinePlot,x,y)
     assert elem(data,0) == x
     assert elem(data, 1) == y

    end
  end
end
