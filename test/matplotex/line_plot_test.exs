defmodule Matplotex.LinePlotTest do
  alias Matplotex.Figure
  alias Matplotex.Figure.LinePlot
  use Matplotex.PlotCase

  setup do
    x = [1, 3, 7, 4, 2, 5, 6]
    y = [1, 3, 7, 4, 2, 5, 6]

    figure = Matplotex.plot(x, y)
    {:ok, %{figure: figure}}
  end

  test "materialyze caculates size for plot area", %{figure: figure} do
    frame_width = 8
    frame_height = 6
    size = {width,height}
    margin 0.1
    font_size = 16
    title_font_size = 26
    ticks = [1,2,3,4,5,6,7]

    assert %Figure{axes: %LinePlot{width: widht, height: height}} = figure|>Matplotex.figure(%{figsize: size, margin: margin})
    |>Matplotex.set_title(title: "The Plot Title", font_size: font_size)
    |>Matplotex.set_xticks(ticks)
    |>Matplotex.set_yticks(ticks)
    |>Matplotex.set_rc_params([x_tick_font_size: 16, y_tick_font_size: 16])
    |> LinePlot.materialize(figure)


    # Width = figsize.width * 100 - 2*margin - tick_space
    # Height  = figsize.height * 1 - 2*margin - title - tick_space
    assert widht == frame_width - 2*margin*width - font_size* 1/72
    assert height == frame_height - 2*margin*height - title_font_size * 1/72 - font_size * 1/72



  end
end
