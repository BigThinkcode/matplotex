defmodule Matplotex.LinePlotTest do
  alias Matplotex.Figure
  alias Matplotex.LinePlot
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
    size = {frame_width, frame_height}
    margin = 0.1
    font_size = 0
    title_font_size = 0
    ticks = [1, 2, 3, 4, 5, 6, 7]

    assert %Figure{
             axes: %LinePlot{size: %{width: width, height: height}, bottom_left_corner: {cx, cy}}
           } =
             figure
             |> Matplotex.figure(%{figsize: size, margin: margin})
             |> Matplotex.set_title("The Plot Title")
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
             |> LinePlot.materialize()

    # Width = figsize.width * 100 - 2*margin - tick_space
    # Height  = figsize.height * 1 - 2*margin - title - tick_space
    expected_frame_width = frame_width - 2 * margin * frame_width
    expected_frame_height = frame_height - 2 * margin * frame_height
    assert round(width) == round(expected_frame_width * 96)
    assert round(height) == round(expected_frame_height * 96)
    # Check bottom-left corner
    assert {cx, cy} ==
             {(frame_width - (expected_frame_width + margin * frame_width)) * 96,
              (frame_height - (expected_frame_height + margin * frame_height)) * 96}
  end
end
