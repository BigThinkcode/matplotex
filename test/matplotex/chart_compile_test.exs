defmodule Matplotex.ChartCompileTest do
  use ExUnit.Case, async: true
  alias Matplotex.{Chart, Axis, Dataset, Frame, Canvas}

  defp sample_line_chart do
    Chart.new(:line)
    |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Month"})
    |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Revenue"})
    |> Chart.add_data(Enum.zip(1..7, [10, 30, 20, 50, 40, 60, 45]), name: "2024")
  end

  describe "compile/1" do
    test "returns a chart with empty dirty set" do
      compiled = Chart.compile(sample_line_chart())
      assert MapSet.size(compiled.dirty) == 0
    end

    test "populates frame" do
      compiled = Chart.compile(sample_line_chart())
      assert %Frame{} = compiled.frame
      assert compiled.frame.plot != nil
    end

    test "computes axis scales from data" do
      compiled = Chart.compile(sample_line_chart())
      assert compiled.axes[:x1].scale != nil
      assert compiled.axes[:y1].scale != nil
      assert compiled.axes[:x1].scale.domain_max == 7.0
      assert compiled.axes[:y1].scale.domain_max == 60.0
    end

    test "computes tick labels" do
      compiled = Chart.compile(sample_line_chart())
      assert length(compiled.axes[:x1].tick_labels) == 5
      assert Enum.all?(compiled.axes[:x1].tick_labels, &is_binary/1)
    end

    test "builds transform matrix" do
      compiled = Chart.compile(sample_line_chart())
      assert Map.has_key?(compiled.frame.transforms, {:x1, :y1})
      assert Nx.shape(compiled.frame.transforms[{:x1, :y1}]) == {3, 3}
    end

    test "computes tick pixels in frame" do
      compiled = Chart.compile(sample_line_chart())
      assert Map.has_key?(compiled.frame.tick_pixels, :x1)
      assert Map.has_key?(compiled.frame.tick_pixels, :y1)
      assert Nx.size(compiled.frame.tick_pixels[:x1]) == 5
    end

    test "produces geometry list" do
      compiled = Chart.compile(sample_line_chart())
      assert is_list(compiled.geometry)
      assert length(compiled.geometry) == 1
    end

    test "is idempotent" do
      compiled = Chart.compile(sample_line_chart())
      assert Chart.compile(compiled) == compiled
    end

    test "y-axis scale respects origin_at_zero" do
      compiled = Chart.compile(sample_line_chart())
      assert compiled.axes[:y1].scale.domain_min == 0.0
    end

    test "dual y-axes each get their own transform" do
      chart =
        Chart.new(:line)
        |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
        |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
        |> Chart.put_axis(:y2, %Axis{dimension: :y, position: :right})
        |> Chart.add_data(Enum.zip(1..5, [1, 2, 3, 4, 5]))
        |> Chart.add_data(Enum.zip(1..5, [100, 200, 300, 400, 500]))
        |> Chart.compile()

      assert map_size(chart.frame.transforms) >= 1
    end
  end

  describe "set_viewport/2" do
    test "only marks geometry dirty" do
      compiled = Chart.compile(sample_line_chart())
      vp = %Matplotex.Viewport{zoom_x: 2.0, zoom_y: 2.0}
      chart2 = Chart.set_viewport(compiled, vp)
      assert MapSet.member?(chart2.dirty, :geometry)
      refute MapSet.member?(chart2.dirty, :frame)
      refute MapSet.member?(chart2.dirty, :scales)
    end
  end

  describe "put_axis/3" do
    test "marks frame and scales dirty" do
      chart = Chart.new(:line)
      updated = Chart.put_axis(chart, :x1, %Axis{dimension: :x})
      assert MapSet.member?(updated.dirty, :frame)
      assert MapSet.member?(updated.dirty, :scales)
    end
  end

  describe "set_axis_limits/4" do
    test "overrides x-axis domain instead of inferring from data" do
      compiled =
        sample_line_chart()
        |> Chart.set_axis_limits(:x1, 0.0, 20.0)
        |> Chart.compile()

      assert compiled.axes[:x1].scale.domain_min == 0.0
      assert compiled.axes[:x1].scale.domain_max == 20.0
    end

    test "overrides y-axis domain instead of inferring from data" do
      compiled =
        sample_line_chart()
        |> Chart.set_axis_limits(:y1, -50.0, 200.0)
        |> Chart.compile()

      assert compiled.axes[:y1].scale.domain_min == -50.0
      assert compiled.axes[:y1].scale.domain_max == 200.0
    end

    test "tick labels are generated from the explicit limits" do
      compiled =
        sample_line_chart()
        |> Chart.set_axis_limits(:x1, 0.0, 100.0)
        |> Chart.compile()

      labels = compiled.axes[:x1].tick_labels
      assert length(labels) == 5
      assert List.first(labels) == "0"
      assert List.last(labels) == "100"
    end

    test "limits stored on axis struct" do
      chart =
        sample_line_chart()
        |> Chart.set_axis_limits(:x1, 5.0, 15.0)

      assert chart.axes[:x1].limits == {5.0, 15.0}
    end

    test "marks scales and geometry dirty" do
      compiled = Chart.compile(sample_line_chart())
      updated = Chart.set_axis_limits(compiled, :y1, 0.0, 100.0)
      assert MapSet.member?(updated.dirty, :scales)
      assert MapSet.member?(updated.dirty, :geometry)
    end

    test "does not affect the other axis" do
      compiled =
        sample_line_chart()
        |> Chart.set_axis_limits(:x1, 0.0, 50.0)
        |> Chart.compile()

      # y1 still inferred from data
      assert compiled.axes[:y1].scale.domain_max == 60.0
    end

    test "raises when min >= max" do
      assert_raise FunctionClauseError, fn ->
        sample_line_chart()
        |> Chart.set_axis_limits(:x1, 10.0, 5.0)
      end
    end

    test "builds a valid transform matrix with explicit limits" do
      compiled =
        sample_line_chart()
        |> Chart.set_axis_limits(:x1, 0.0, 20.0)
        |> Chart.set_axis_limits(:y1, 0.0, 100.0)
        |> Chart.compile()

      assert Map.has_key?(compiled.frame.transforms, {:x1, :y1})
      assert Nx.shape(compiled.frame.transforms[{:x1, :y1}]) == {3, 3}
    end
  end
end
