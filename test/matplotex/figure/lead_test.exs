defmodule Matplotex.Figure.LeadTest do
  alias Matplotex.Figure.Areal.Region
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure.LinePlot
  alias Matplotex.Figure
  alias Matplotex.Figure.Areal.LinePlot
  use Matplotex.PlotCase
  alias Matplotex.Figure.Lead

  # all the padding and tickline spaces
  @padding_and_tick_line_space 25 / 96
  @padding 10 / 96

  setup do
    figure = Matplotex.FrameHelpers.sample_figure()

    frame_width = 8
    frame_height = 6
    size = {frame_width, frame_height}
    margin = 0.1
    x = [1, 3, 7, 4, 2, 5, 6]
    y = [1, 3, 7, 4, 2, 5, 6]
    ticks = [1, 2, 3, 4, 5, 6, 7]

    figure2 =
      x
      |> Matplotex.plot(y)
      |> Matplotex.figure(%{figsize: size, margin: margin})
      |> Matplotex.set_title("The Plot Title")
      |> Matplotex.set_xticks(ticks)
      |> Matplotex.set_yticks(ticks)

    {:ok, %{figure: figure, figure2: figure2}}
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
                 title: _title,
                 coords: %Coords{
                   bottom_left: {blx, bly},
                   bottom_right: {brx, bry},
                   top_right: {trx, ytr},
                   top_left: {tlx, tly}
                 }
               }
             } =
               Lead.set_spines(figure)

      # Check bottom-left corner
      assert blx == frame_width * margin + @padding_and_tick_line_space

      assert Float.floor(bly, 7) ==
               Float.floor(frame_height * margin + @padding_and_tick_line_space, 7)

      # Check bottom-right corner
      assert brx == frame_width - frame_width * margin
      # + @padding_and_tick_line_space
      assert Float.floor(bry, 8) ==
               Float.floor(frame_height * margin + @padding_and_tick_line_space, 8)

      # Check top-right corner
      assert trx == frame_width - frame_width * margin
      # + @padding_and_tick_line_space
      assert ytr == frame_height - frame_height * margin - @padding
      # + @padding_and_tick_line_space
      # Check top-left corner
      assert tlx == frame_width * margin + @padding_and_tick_line_space
      assert tly == frame_height - frame_height * margin - @padding
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
                 coords: %Coords{
                   top_left: {_tlx, tly},
                   top_right: {_trx, ytr}
                 }
               }
             } =
               Lead.set_spines(figure)

      assert Float.round(tly, 10) ==
               Float.round(frame_height - (title_font_size / 150 + 10 / 96), 10)

      # the offset of the title
      assert Float.round(ytr, 10) ==
               Float.round(frame_height - (title_font_size / 150 + 10 / 96), 10)
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

      assert Float.round(bly, 10) ==
               Float.round(font_size / 150 + @padding_and_tick_line_space, 10)

      assert Float.round(bry, 10) ==
               Float.round(font_size / 150 + @padding_and_tick_line_space, 10)
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

      assert Float.round(tlx, 10) ==
               Float.round(font_size / 150 + @padding_and_tick_line_space, 10)

      assert Float.round(blx, 10) ==
               Float.round(font_size / 150 + @padding_and_tick_line_space, 10)
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

      assert bly == font_size / 150 + @padding_and_tick_line_space
      assert bry == font_size / 150 + @padding_and_tick_line_space
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

      assert tlx == font_size / 150 + @padding_and_tick_line_space
      assert blx == font_size / 150 + @padding_and_tick_line_space
    end
  end

  describe "set_regions/1" do
    test "sets region_xy", %{figure2: figure} do
      assert %Figure{
               axes: %{
                 region_x: %Region{x: rxx, y: rxy, width: rxwidth, height: rxheight},
                 region_y: %Region{x: ryx, y: ryy, width: rywidth, height: ryheight}
               }
             } = Lead.set_regions(figure)

      assert Enum.all?([rxx, rxwidth, rxheight, ryy, rywidth, ryheight], &(&1 > 0))
      assert Enum.all?([rxy, ryx], &(&1 == 0))
    end

    test "set region title updates the values for titles space", %{figure2: figure} do
      assert %Figure{
               axes: %{
                 region_title: %Region{x: rtx, y: rty, width: rtwidth, height: rtheight}
               }
             } = Lead.set_regions(figure)

      assert Enum.all?([rtx, rty, rtwidth, rtheight], &(&1 > 0))
    end

    test "setting region legend", %{figure2: figure} do
      figure = Matplotex.show_legend(figure)

      assert %Figure{
               axes: %{
                 region_legend: %Region{x: rlx, y: rly, width: rlwidth, height: rlheight}
               }
             } = Lead.set_regions(figure)

      assert Enum.all?([rlx, rly, rlwidth, rlheight], &(&1 > 0))
    end
    test "setting content takes the same width of x region and y region", %{figure2: figure} do

      assert %Figure{
        axes: %{
          region_x: %Region{x: rxx, width: rxwidth},
          region_y: %Region{y: ryy, height: ryheight},
          region_content: %Region{x: rcx, y: rcy, width: rcwidth, height: rcheight}
        }
      } = Lead.set_regions(figure)

      assert rxx == rcx
      assert ryy == rcy
      assert rcwidth == rxwidth
      assert ryheight == rcheight
    end
  end
end
