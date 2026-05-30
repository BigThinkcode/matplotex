defmodule Matplotex.SVGRenderTest do
  use ExUnit.Case, async: true
  alias Matplotex.{Chart, Axis, Dataset}
  alias Matplotex.Render.SVG

  defp compiled_line do
    Chart.new(:line, canvas: %Matplotex.Canvas{figsize: {8, 5}})
    |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "X"})
    |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Y"})
    |> Chart.add_data(Enum.zip(1..5, [2, 4, 1, 5, 3]), name: "s1", color: "#10B981")
    |> Chart.set_title("Test Chart")
    |> Chart.compile()
  end

  describe "to_svg/1" do
    test "returns a binary" do
      assert is_binary(SVG.to_svg(compiled_line()))
    end

    test "wraps in <svg> tag" do
      svg = SVG.to_svg(compiled_line())
      assert String.starts_with?(svg, "<svg ")
      assert String.ends_with?(svg, "</svg>")
    end

    test "uses canvas dimensions in svg tag" do
      svg = SVG.to_svg(compiled_line())
      assert svg =~ ~s(width="768.0")
      assert svg =~ ~s(height="480.0")
    end

    test "includes title text" do
      svg = SVG.to_svg(compiled_line())
      assert svg =~ "Test Chart"
    end

    test "includes axis labels" do
      svg = SVG.to_svg(compiled_line())
      assert svg =~ ">X<"
      assert svg =~ ">Y<"
    end

    test "includes tick labels" do
      svg = SVG.to_svg(compiled_line())
      assert svg =~ ~r/<text[^>]+>\d+<\/text>/
    end

    test "includes grid lines" do
      svg = SVG.to_svg(compiled_line())
      assert svg =~ "stroke-dasharray"
    end

    test "includes path for line series" do
      svg = SVG.to_svg(compiled_line())
      assert svg =~ "<path"
      assert svg =~ ~s(stroke="#10B981")
    end

    test "has matching open/close svg tags" do
      svg = SVG.to_svg(compiled_line())
      open  = svg |> String.split("<svg")  |> length() |> Kernel.-(1)
      close = svg |> String.split("</svg>") |> length() |> Kernel.-(1)
      assert open == close
    end
  end

  describe "bar chart SVG" do
    test "includes rect elements" do
      chart =
        Chart.new(:bar)
        |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
        |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
        |> Chart.add_data(Enum.zip(1..3, [10, 20, 15]))
        |> Chart.compile()

      assert SVG.to_svg(chart) =~ "<rect"
    end
  end

  describe "scatter chart SVG" do
    test "includes circle elements" do
      chart =
        Chart.new(:scatter)
        |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
        |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
        |> Chart.add_data(Enum.zip(1..4, [3, 1, 4, 1]))
        |> Chart.compile()

      assert SVG.to_svg(chart) =~ "<circle"
    end
  end

  describe "pie chart SVG" do
    test "includes arc path elements" do
      ds = Dataset.from_columns(y: [30.0, 50.0, 20.0])
      chart = Chart.new(:pie) |> Chart.put_dataset(ds) |> Chart.compile()
      svg = SVG.to_svg(chart)
      assert svg =~ "<path"
      assert svg =~ ~r/ A \d/
    end
  end

  describe "donut chart SVG" do
    test "produces valid SVG with arc paths" do
      ds = Dataset.from_columns(y: [40.0, 60.0])
      chart = Chart.new(:donut) |> Chart.put_dataset(ds) |> Chart.compile()
      svg = SVG.to_svg(chart)
      assert is_binary(svg)
      assert svg =~ "<path"
    end
  end

  describe "area chart SVG" do
    test "includes a filled path" do
      chart =
        Chart.new(:area)
        |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
        |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
        |> Chart.add_data(Enum.zip(1..5, [1, 3, 2, 5, 4]))
        |> Chart.compile()

      svg = SVG.to_svg(chart)
      assert svg =~ ~r/fill="[^"n][^"]*"/  # fill is not "none"
    end
  end

  describe "step chart SVG" do
    test "produces a valid path" do
      chart =
        Chart.new(:step)
        |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
        |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
        |> Chart.add_data(Enum.zip(1..4, [1, 3, 2, 4]))
        |> Chart.compile()

      assert SVG.to_svg(chart) =~ "<path"
    end
  end
end
