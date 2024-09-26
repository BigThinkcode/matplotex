defmodule Matplotex.LinePlotTest do
  use Matplotex.PlotCase

  setup do
    x = [1, 3, 7, 4, 2, 5, 6]
    y = [1, 3, 7, 4, 2, 5, 6]

    figure = Matplotex.plot(x, y)
    {:ok, %{figure: figure}}
  end

  test "materialyze caculates size for plot area", %{figure: figure} do
  end
end
