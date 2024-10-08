defmodule Matplotex.Figure.LeadTest do
  alias Matplotex.Figure.Sketch
  alias Matplotex.Figure.Coords
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
    test "sets coordinates of spines in a figure by reducing margin", %{figure: figure} do
      frame_width = 8
      frame_height = 6

      margin = 0.1
      font_size = 0
      title_font_size = 0

      figure =
        figure
        |> Matplotex.figure(%{margin: margin})
        |> Matplotex.set_rc_params(%{
          x_tick_font_size: font_size,
          y_tick_font_size: font_size,
          title_font_size: title_font_size,
          x_label_font_size: font_size,
          y_label_font_size: font_size
        })

      assert %Figure{
               axes: %LinePlot{
                 size: %{width: width, height: height},
                 coords: %Coords{
                   bottom_left: {blx, bly},
                   bottom_right: {brx, bry},
                   top_right: {trx, ytr},
                   top_left: {tlx, tly}
                 }
               }
             } =
               Lead.set_spines(figure)

      # Width = figsize.width * 100 - 2*margin - tick_space
      # Height  = figsize.height * 1 - 2*margin - title - tick_space
      expected_frame_width = frame_width - 2 * margin * frame_width
      expected_frame_height = frame_height - 2 * margin * frame_height
      assert round(width) == round(expected_frame_width * 96)
      assert round(height) == round(expected_frame_height * 96)
      # Check bottom-left corner
      assert blx == frame_width * margin * 96
      assert bly == frame_height * margin * 96
      # Check bottom-right corner
      assert brx == (frame_width - frame_width * margin) * 96
      assert bry == (frame_height - frame_height * margin) * 96
      # Check top-right corner
      assert trx == (frame_width - frame_width * margin) * 96
      assert ytr == (frame_height - frame_height * margin) * 96
      # Check top-left corner
      assert tlx == frame_width * margin * 96
      assert tly == (frame_height - frame_height * margin) * 96
    end

    test "sets coordinates by reducing title height", %{figure: figure} do
      frame_height = 6

      margin = 0
      font_size = 0
      title_font_size = 18

      figure =
        figure
        |> Matplotex.figure(%{margin: margin})
        |> Matplotex.set_rc_params(
          x_tick_font_size: font_size,
          y_tick_font_size: font_size,
          title_font_size: title_font_size,
          x_label_font_size: font_size,
          y_label_font_size: font_size
        )

      assert %Figure{
               axes: %LinePlot{
                 size: %{width: width, height: height},
                 coords: %Coords{
                   top_left: {_tlx, tly},
                   top_right: {_trx, ytr}
                 }
               }
             } =
               Lead.set_spines(figure)

      assert tly == frame_height - title_font_size / 72
      assert ytr == frame_height - title_font_size / 72
    end

    test "sets coordinates by reducing xlabel", %{figure: figure} do
      margin = 0
      font_size = 16
      title_font_size = 0

      figure =
        figure
        |> Matplotex.figure(%{margin: margin})
        |> Matplotex.set_rc_params(
          x_tick_font_size: 0,
          y_tick_font_size: 0,
          title_font_size: title_font_size,
          x_label_font_size: font_size,
          y_label_font_size: 0
        )

      assert %Figure{
               axes: %LinePlot{
                 coords: %Coords{
                   bottom_left: {_blx, bly},
                   bottom_right: {_brx, bry}
                 }
               }
             } =
               Lead.set_spines(figure)

      assert bly == font_size / 72 + 10 / 96
      assert bry == font_size / 72 + 10 / 96
    end

    test "sets coordinates by reducing ylabel", %{figure: figure} do
      margin = 0
      font_size = 16
      title_font_size = 0

      figure =
        figure
        |> Matplotex.figure(%{margin: margin})
        |> Matplotex.set_rc_params(
          x_tick_font_size: 0,
          y_tick_font_size: 0,
          title_font_size: title_font_size,
          x_label_font_size: 0,
          y_label_font_size: font_size
        )

      assert %Figure{
               axes: %LinePlot{
                 coords: %Coords{
                   bottom_left: {blx, _bly},
                   top_left: {tlx, _tly}
                 }
               }
             } =
               Lead.set_spines(figure)

      assert tlx == font_size / 72 + 10 / 96
      assert blx == font_size / 72 + 10 / 96
    end

    test "set coordinates by reducing xticks", %{figure: figure} do
      margin = 0
      font_size = 16
      title_font_size = 0

      figure =
        figure
        |> Matplotex.figure(%{margin: margin})
        |> Matplotex.set_rc_params(
          x_tick_font_size: font_size,
          y_tick_font_size: 0,
          title_font_size: title_font_size,
          x_label_font_size: 0,
          y_label_font_size: 0
        )

      assert %Figure{
               axes: %LinePlot{
                 coords: %Coords{
                   bottom_left: {_blx, bly},
                   bottom_right: {_brx, bry}
                 }
               }
             } =
               Lead.set_spines(figure)

      assert bly == font_size / 72 + 10 / 96
      assert bry == font_size / 72 + 10 / 96
    end

    test "set coordinates by reducing yticks", %{figure: figure} do
      margin = 0
      font_size = 16
      title_font_size = 0

      figure =
        figure
        |> Matplotex.figure(%{margin: margin})
        |> Matplotex.set_rc_params(
          x_tick_font_size: 0,
          y_tick_font_size: font_size,
          title_font_size: title_font_size,
          x_label_font_size: 0,
          y_label_font_size: 0
        )

      assert %Figure{
               axes: %LinePlot{
                 coords: %Coords{
                   bottom_left: {blx, _bly},
                   top_left: {tlx, _tly}
                 }
               }
             } =
               Lead.set_spines(figure)

      assert tlx == font_size / 72 + 10 / 96
      assert blx == font_size / 72 + 10 / 96
    end
  end

  describe "draw_spines/1" do
    test "add elements for borders in axes", %{figure: figure} do
      assert %Figure{axes: %{element: elements}} =
               figure |> Lead.set_spines() |> Lead.draw_spines()

      assert Enum.filter(elements, fn x -> x.type == "spine.top" end) |> length() == 1
      assert Enum.filter(elements, fn x -> x.type == "spine.bottom" end) |> length() == 1
      assert Enum.filter(elements, fn x -> x.type == "spine.right" end) |> length() == 1
      assert Enum.filter(elements, fn x -> x.type == "spine.left" end) |> length() == 1
    end
  end

  test "add element for title in axes", %{figure: figure} do
    assert %Figure{axes: %{element: elements}} =
             figure = figure |> Lead.set_spines() |> Lead.draw_spines() |> Lead.entitle()

    assert Enum.filter(elements, fn x -> x.type == "figure.title" end) |> length == 1
  end
end
