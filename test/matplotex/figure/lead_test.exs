defmodule Matplotex.Figure.LeadTest do
  alias Matplotex.Figure.LinePlot
  alias Matplotex.Figure
  alias Matplotex.LinePlot
  use Matplotex.PlotCase
  alias Matplotex.Figure.Lead

  setup do
    x = [1, 3, 7, 4, 2, 5, 6]
    y = [1, 3, 7, 4, 2, 5, 6]



    frame_width = 8
    frame_height = 6
    size = {frame_width, frame_height}
    margin = 0.1
    font_size = 0
    title_font_size = 0
    ticks = [1, 2, 3, 4, 5, 6, 7]

    figure =
      x
      |> Matplotex.plot(y)
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

    {:ok, %{figure: figure}}
  end
  describe "set_spines/1" do
    test "sets coordinates of spines in a figure", %{figure: figure} do
    frame_width = 8
    frame_height = 6
    size = {frame_width, frame_height}
    margin = 0.1
    font_size = 0
    title_font_size = 0
    ticks = [1, 2, 3, 4, 5, 6, 7]

    assert %Figure{
             axes: %LinePlot{size: %{width: width, height: height}, bottom_left: {cx, cy}, bottom_right: {brx, _bry}}
           } =
              Lead.set_spines(figure)

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
    assert brx == (frame_width - frame_width * margin) * 96
  end
  end
  describe "draw_spines/1" do
  test "add elements for borders in axes", %{figure: figure} do
    assert %Figure{axes: %{element: elements}} = figure|>Lead.set_spines()|>Lead.draw_spines()
    assert Enum.filter(elements, fn x -> x.type == "spine.top" end) |> length() == 1
    assert Enum.filter(elements, fn x -> x.type == "spine.bottom" end) |> length() == 1
    assert Enum.filter(elements, fn x -> x.type == "spine.right" end) |> length() == 1
    assert Enum.filter(elements, fn x -> x.type == "spine.left" end) |> length() == 1
  end
  end
  test "add element for title in axes", %{figure_with_spines: figure} do
    assert %Figure{axes: %{element: elements}} = Lead.entitle(figure)
    assert Enum.filter(elements, fn x -> x.type == "figure.title" end) |> length == 1
  end

end
