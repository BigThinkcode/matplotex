defmodule Matplotex.Figure.LeadTest do
  alias Matplotex.Figure.TwoD
  alias Matplotex.Figure.Areal.Region
  alias Matplotex.Figure
  use Matplotex.PlotCase
  alias Matplotex.Figure.Lead


  setup(context) do
    figure =
      if context.radial do
        categories = ["2008", "2009", "2010", "2011"]
        values = [18.48923375, 17.1923791, 17.48479218, 17.02021634]

        colors = ["#76b5c5", "#DEDEDE", "#FBD1A2", "#6195B4"]
        Matplotex.pie(values, colors: colors, labels: categories)
      else
        Matplotex.FrameHelpers.sample_figure()
      end


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

  describe "set_regions_areal/1" do
    test "sets region_xy", %{figure2: figure} do
      assert %Figure{
               axes: %{
                 region_x: %Region{x: rxx, y: rxy, width: rxwidth, height: rxheight},
                 region_y: %Region{x: ryx, y: ryy, width: rywidth, height: ryheight}
               }
             } = Lead.set_regions_areal(figure)

      assert Enum.all?([rxx, rxy, rxwidth, rxheight, ryx, ryy, rywidth, ryheight], &(&1 != 0))
    end

    test "set region title updates the values for titles space", %{figure2: figure} do
      assert %Figure{
               axes: %{
                 region_title: %Region{x: rtx, y: rty, width: rtwidth, height: rtheight}
               }
             } = Lead.set_regions_areal(figure)

      assert Enum.all?([rtx, rty, rtwidth, rtheight], &(&1 != 0))
    end

    test "setting region legend", %{figure2: figure} do
      figure = Matplotex.show_legend(figure)

      assert %Figure{
               axes: %{
                 region_legend: %Region{x: rlx, y: rly, width: rlwidth, height: rlheight}
               }
             } = Lead.set_regions_areal(figure)

      assert Enum.all?([rlx, rly, rlwidth, rlheight], &(&1 != 0))
    end

    test "setting content takes the same width of x region and y region", %{figure2: figure} do
      assert %Figure{
               axes: %{
                 region_x: %Region{x: rxx, width: rxwidth},
                 region_y: %Region{y: ryy, height: ryheight},
                 region_content: %Region{x: rcx, y: rcy, width: rcwidth, height: rcheight}
               }
             } = Lead.set_regions_areal(figure)

      assert rxx == rcx
      assert ryy == rcy
      assert rcwidth == rxwidth
      assert ryheight == rcheight
    end

    test "generates ticks from dataset if does't exist for show_ticks true", %{
      figure2: %Figure{axes: %{tick: tick} = axes} = figure
    } do
      figure = %Figure{
        figure
        | axes: %{axes | tick: %TwoD{tick | x: nil, y: nil}, limit: %TwoD{x: nil, y: nil}}
      }

      assert %Figure{
               figsize: {width, height},
               axes: %{
                 tick: %TwoD{x: xticks, y: yticks},
                 data: {x, y}
               }
             } = Lead.set_regions_areal(figure)

      assert Enum.min(xticks) == 0
      assert Enum.min(yticks) == 0
      assert Enum.max(xticks) == Enum.max(x)
      assert Enum.max(yticks) == Enum.max(y)
      assert length(xticks) == ceil(width)
      assert length(yticks) == ceil(height)
    end
  end

  test "all coordinates will be zero if input is zero", %{figure2: figure} do
    figure = Matplotex.figure(figure, %{figsize: {0, 0}})

    assert %Figure{
             axes: %{
               region_x: %Region{x: rxx, width: rxwidth},
               region_y: %Region{y: ryy, height: ryheight},
               region_title: %Region{x: rtx, y: rty, width: rtwidth, height: rtheight},
               region_content: %Region{x: rcx, y: rcy, width: rcwidth, height: rcheight}
             }
           } = Lead.set_regions_areal(figure)

    assert rxx == 0
    assert ryy == 0
    assert rtx == 0
    assert rty == 0
    assert rtwidth == 0
    assert rtheight == 0
    assert rcx == 0
    assert rcy == 0
    assert rcwidth == 0
    assert rcheight == 0
    assert ryheight == 0
    assert rxwidth == 0
  end

  test "height will tally with all vertical components", %{figure: figure} do
    assert %Figure{
             figsize: {_width, height},
             margin: margin,
             axes: %{
               region_x: %Region{height: rxheight},
               region_title: %Region{height: rtheight},
               region_content: %Region{height: rcheight}
             }
           } = Lead.set_regions_areal(figure)

    margin_two_side = height * margin * 2
    assert height == margin_two_side + rxheight + rtheight + rcheight
  end

  test "width will tally with all horizontal components", %{figure: figure} do
    assert %Figure{
             figsize: {width, _height},
             margin: margin,
             axes: %{
               region_y: %Region{width: ry_width},
               region_content: %Region{width: rcwidth},
               region_legend: %Region{width: rlwidth}
             }
           } = Lead.set_regions_areal(figure)

    two_side_margin = width * margin * 2
    assert width == two_side_margin + ry_width + rcwidth + rlwidth
  end

  describe "set_regions_areal" do
    @tag radial: true
    test "updates with all borders" do
    %Figure{axes: %{border: {lx, by, rx, ty}}} = Lead.set_regions_radial(figure)
      assert lx > 0 && by > 0 && rx > 0 && ty > 0
    end
    @tag radial: true
    test "updates region titles" do
      %Figure{axes: %{region_title: %Region{}}} = Lead.set_regions_radial(figure)
    end

  end
end
