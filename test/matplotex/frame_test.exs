defmodule Matplotex.FrameTest do
  use ExUnit.Case, async: true
  alias Matplotex.{Frame, Canvas, Axis}

  defp chart_with_axes do
    %{
      canvas: %Canvas{figsize: {8, 5}, dpi: 96, margin: 0.05},
      title:  nil,
      axes: %{
        x1: %Axis{id: :x1, dimension: :x, position: :bottom},
        y1: %Axis{id: :y1, dimension: :y, position: :left}
      },
      frame: nil
    }
  end

  describe "compute/1" do
    test "populates frame with Nx tensors" do
      chart = Frame.compute(chart_with_axes())
      assert %Frame{} = chart.frame
      assert chart.frame.canvas_px != nil
      assert chart.frame.plot != nil
    end

    test "canvas_px matches figsize × dpi" do
      chart = Frame.compute(chart_with_axes())
      assert Nx.to_number(chart.frame.canvas_px[0]) == 8 * 96 * 1.0
      assert Nx.to_number(chart.frame.canvas_px[1]) == 5 * 96 * 1.0
    end

    test "plot region is strictly inside margin box" do
      chart = Frame.compute(chart_with_axes())
      plot = chart.frame.plot
      canvas_w = 8 * 96 * 1.0
      canvas_h = 5 * 96 * 1.0
      margin = 0.05

      assert Nx.to_number(plot[0]) > canvas_w * margin
      assert Nx.to_number(plot[1]) >= canvas_h * margin
      assert Nx.to_number(plot[0]) + Nx.to_number(plot[2]) <= canvas_w * (1 - margin)
      assert Nx.to_number(plot[1]) + Nx.to_number(plot[3]) <= canvas_h * (1 - margin)
    end

    test "plot width and height are positive" do
      chart = Frame.compute(chart_with_axes())
      assert Nx.to_number(chart.frame.plot[2]) > 0
      assert Nx.to_number(chart.frame.plot[3]) > 0
    end

    test "axis regions are populated for each declared axis" do
      chart = Frame.compute(chart_with_axes())
      assert Map.has_key?(chart.frame.axis_regions, :x1)
      assert Map.has_key?(chart.frame.axis_regions, :y1)
    end

    test "axis regions are Nx tensors of shape {4}" do
      chart = Frame.compute(chart_with_axes())
      r = chart.frame.axis_regions[:x1]
      assert Nx.shape(r) == {4}
    end

    test "title region has zero height when no title" do
      chart = Frame.compute(chart_with_axes())
      assert Nx.to_number(chart.frame.title[3]) == 0.0
    end

    test "title region has positive height when title present" do
      chart = chart_with_axes() |> Map.put(:title, "My Chart")
      result = Frame.compute(chart)
      assert Nx.to_number(result.frame.title[3]) > 0
    end

    test "right-side axis increases left boundary of plot" do
      chart_base = Frame.compute(chart_with_axes())

      chart_dual =
        Frame.compute(%{chart_with_axes() | axes: Map.put(chart_with_axes().axes, :y2,
          %Axis{id: :y2, dimension: :y, position: :right})})

      # plot should be narrower with a right axis
      w_base = Nx.to_number(chart_base.frame.plot[2])
      w_dual = Nx.to_number(chart_dual.frame.plot[2])
      assert w_dual < w_base
    end
  end

  describe "compute_tick_pixels/2" do
    test "returns tick tensors for axes that have scales" do
      chart = Frame.compute(chart_with_axes())
      axes_with_scale = %{
        x1: %Axis{id: :x1, dimension: :x, position: :bottom, tick_count: 5,
                  scale: %{domain_min: 0.0, domain_max: 10.0, type: :linear}},
        y1: %Axis{id: :y1, dimension: :y, position: :left,   tick_count: 5,
                  scale: %{domain_min: 0.0, domain_max: 100.0, type: :linear}}
      }
      frame = Frame.compute_tick_pixels(chart.frame, axes_with_scale)
      assert Map.has_key?(frame.tick_pixels, :x1)
      assert Map.has_key?(frame.tick_pixels, :y1)
      assert Nx.size(frame.tick_pixels[:x1]) == 5
    end

    test "x-axis ticks span plot width" do
      chart = Frame.compute(chart_with_axes())
      axes_with_scale = %{
        x1: %Axis{id: :x1, dimension: :x, position: :bottom, tick_count: 5,
                  scale: %{domain_min: 0.0, domain_max: 10.0, type: :linear}}
      }
      frame = Frame.compute_tick_pixels(chart.frame, axes_with_scale)
      ticks = Nx.to_list(frame.tick_pixels[:x1])
      plot_x = Nx.to_number(chart.frame.plot[0])
      plot_r = plot_x + Nx.to_number(chart.frame.plot[2])
      assert_in_delta hd(ticks),         plot_x, 0.5
      assert_in_delta List.last(ticks),  plot_r, 0.5
    end

    test "y-axis ticks go from bottom to top (SVG flip)" do
      chart = Frame.compute(chart_with_axes())
      axes_with_scale = %{
        y1: %Axis{id: :y1, dimension: :y, position: :left, tick_count: 5,
                  scale: %{domain_min: 0.0, domain_max: 10.0, type: :linear}}
      }
      frame = Frame.compute_tick_pixels(chart.frame, axes_with_scale)
      ticks = Nx.to_list(frame.tick_pixels[:y1])
      # domain_min maps to bottom (higher y), domain_max maps to top (lower y)
      assert hd(ticks) > List.last(ticks)
    end
  end
end
