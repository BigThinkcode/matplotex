defmodule Matplotex.ChartTypesCriticalTest do
  @moduledoc """
  Critical-path coverage for the remaining untested chart types
  (box, bubble, donut) plus a smoke test that *every* supported type
  compiles and renders to valid SVG without raising.
  """
  use ExUnit.Case, async: true

  alias Matplotex.{Chart, Axis, Dataset}
  alias Matplotex.Geom.{Path, Rects, Circles, Arcs, Segments}
  alias Matplotex.Render.SVG

  defp with_xy_axes(chart) do
    chart
    |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
    |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
  end

  defp geom0(chart), do: hd(chart.geometry)

  # ── Box plot ─────────────────────────────────────────────────────────────

  describe "box plot" do
    # two groups (x = 1 and x = 2), each with a spread of samples
    defp box_chart do
      xs = List.duplicate(1.0, 6) ++ List.duplicate(2.0, 6)
      ys = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0] ++ [10.0, 20.0, 30.0, 40.0, 50.0, 60.0]
      ds = Dataset.from_columns(x: xs, y: ys)
      Chart.new(:box) |> with_xy_axes() |> Chart.put_dataset(ds) |> Chart.compile()
    end

    test "produces both a box (Rects) and whiskers (Segments)" do
      geoms = geom0(box_chart())
      assert Enum.any?(geoms, &match?(%Rects{}, &1))
      assert Enum.any?(geoms, &match?(%Segments{}, &1))
    end

    test "one box rect per group" do
      geoms = geom0(box_chart())
      [%Rects{xywh: xywh}] = Enum.filter(geoms, &match?(%Rects{}, &1))
      {_, n} = Nx.shape(xywh)
      assert n == 2
    end

    test "five whisker/cap/median segments per group" do
      geoms = geom0(box_chart())
      [%Segments{x1y1x2y2: segs}] = Enum.filter(geoms, &match?(%Segments{}, &1))
      {4, n} = Nx.shape(segs)
      assert n == 5 * 2
    end

    test "box heights (q1→q3 span) are positive" do
      geoms = geom0(box_chart())
      [%Rects{xywh: xywh}] = Enum.filter(geoms, &match?(%Rects{}, &1))
      heights = xywh[3] |> Nx.to_list()
      assert Enum.all?(heights, &(&1 > 0))
    end

    test "renders line and rect elements" do
      svg = SVG.to_svg(box_chart())
      assert svg =~ "<line"
      assert svg =~ "<rect"
    end
  end

  # ── Bubble chart ───────────────────────────────────────────────────────────

  describe "bubble chart" do
    defp bubble_chart(zs) do
      n = length(zs)
      ds = Dataset.from_columns(x: Enum.to_list(1..n) |> Enum.map(&(&1 * 1.0)),
                                y: Enum.to_list(1..n) |> Enum.map(&(&1 * 1.0)),
                                z: zs)
      Chart.new(:bubble) |> with_xy_axes() |> Chart.put_dataset(ds) |> Chart.compile()
    end

    test "produces a Circles geom, one circle per point" do
      [%Circles{cxcyr: cxcyr}] = geom0(bubble_chart([1.0, 4.0, 9.0]))
      {3, n} = Nx.shape(cxcyr)
      assert n == 3
    end

    test "radii stay within the configured pixel range (4..40)" do
      [%Circles{cxcyr: cxcyr}] = geom0(bubble_chart([1.0, 5.0, 12.0, 30.0]))
      radii = cxcyr[2] |> Nx.to_list()
      assert Enum.all?(radii, &(&1 >= 4.0 and &1 <= 40.0))
    end

    test "smallest z maps to min radius, largest z to max radius" do
      [%Circles{cxcyr: cxcyr}] = geom0(bubble_chart([2.0, 8.0, 50.0]))
      radii = cxcyr[2] |> Nx.to_list()
      assert_in_delta Enum.min(radii), 4.0, 0.001
      assert_in_delta Enum.max(radii), 40.0, 0.001
    end

    test "radius grows monotonically with z" do
      [%Circles{cxcyr: cxcyr}] = geom0(bubble_chart([1.0, 2.0, 3.0, 4.0]))
      radii = cxcyr[2] |> Nx.to_list()
      assert radii == Enum.sort(radii)
    end

    test "renders circle elements" do
      assert SVG.to_svg(bubble_chart([1.0, 4.0, 9.0])) =~ "<circle"
    end
  end

  # ── Donut chart ──────────────────────────────────────────────────────────────

  describe "donut chart" do
    defp donut_chart(values) do
      ds = Dataset.from_columns(y: values)
      Chart.new(:donut) |> Chart.put_dataset(ds) |> Chart.compile()
    end

    test "produces an Arcs geom with a hollow centre (inner_radius > 0)" do
      [%Arcs{inner_radius: inner}] = geom0(donut_chart([30.0, 50.0, 20.0]))
      assert inner > 0.0
    end

    test "inner radius is strictly smaller than outer radius" do
      [%Arcs{inner_radius: inner, outer_radius: outer}] = geom0(donut_chart([40.0, 60.0]))
      assert inner < outer
    end

    test "arc count matches slice count" do
      [%Arcs{start_angles: sa}] = geom0(donut_chart([10.0, 20.0, 30.0, 40.0]))
      assert Nx.size(sa) == 4
    end

    test "slices sweep a full circle (end at 2π)" do
      [%Arcs{end_angles: ea}] = geom0(donut_chart([25.0, 25.0, 50.0]))
      total = ea |> Nx.to_list() |> List.last()
      assert_in_delta total, 2.0 * :math.pi(), 0.001
    end

    test "renders arc path elements" do
      svg = SVG.to_svg(donut_chart([40.0, 60.0]))
      assert svg =~ "<path"
      assert svg =~ ~r/ A \d/
    end
  end

  # ── Smoke test: every supported type compiles & renders ──────────────────────

  describe "all supported types render valid SVG" do
    @xy Enum.zip(1..6, [3, 1, 4, 1, 5, 9])

    # Builds a minimal but valid chart for each supported type.
    defp build(type) when type in [:line, :bar, :scatter, :area, :step, :spline] do
      Chart.new(type) |> with_xy_axes() |> Chart.add_data(@xy) |> Chart.compile()
    end

    defp build(:histogram) do
      samples = Enum.map(1..40, &(&1 * 1.0))
      ds = Dataset.from_columns(x: samples, y: samples)
      Chart.new(:histogram) |> with_xy_axes() |> Chart.put_dataset(ds) |> Chart.compile()
    end

    defp build(type) when type in [:pie, :donut, :funnel, :radar] do
      ds = Dataset.from_columns(y: [30.0, 50.0, 20.0, 40.0])
      Chart.new(type) |> Chart.put_dataset(ds) |> Chart.compile()
    end

    defp build(type) when type in [:box, :violin] do
      xs = List.duplicate(1.0, 8) ++ List.duplicate(2.0, 8)
      ys = Enum.map(1..8, &(&1 * 1.0)) ++ Enum.map(1..8, &(10.0 + &1))
      ds = Dataset.from_columns(x: xs, y: ys)
      Chart.new(type) |> with_xy_axes() |> Chart.put_dataset(ds) |> Chart.compile()
    end

    defp build(:bubble) do
      ds = Dataset.from_columns(x: [1.0, 2.0, 3.0], y: [1.0, 2.0, 3.0], z: [1.0, 5.0, 10.0])
      Chart.new(:bubble) |> with_xy_axes() |> Chart.put_dataset(ds) |> Chart.compile()
    end

    defp build(:heatmap) do
      xs = for _ <- 0..2, c <- 0..2, do: c * 1.0
      ys = for r <- 0..2, _ <- 0..2, do: r * 1.0
      zs = Enum.map(0..8, &(&1 * 1.0))
      ds = Dataset.from_columns(x: xs, y: ys, z: zs)
      Chart.new(:heatmap) |> with_xy_axes() |> Chart.put_dataset(ds) |> Chart.compile()
    end

    defp build(:waterfall) do
      ds = Dataset.from_columns(x: [1.0, 2.0, 3.0, 4.0], y: [10.0, -5.0, 8.0, -2.0])
      Chart.new(:waterfall) |> with_xy_axes() |> Chart.put_dataset(ds) |> Chart.compile()
    end

    defp build(:candlestick) do
      ds = %Dataset{
        x: Nx.tensor([1.0, 2.0, 3.0], type: :f64),
        y: Nx.tensor([15.0, 12.0, 17.0], type: :f64),
        extra: %{
          open: Nx.tensor([10.0, 15.0, 12.0], type: :f64),
          high: Nx.tensor([16.0, 16.0, 18.0], type: :f64),
          low:  Nx.tensor([9.0, 11.0, 11.0], type: :f64)
        }
      }
      Chart.new(:candlestick) |> with_xy_axes() |> Chart.put_dataset(ds) |> Chart.compile()
    end

    for type <- Matplotex.Chart.supported_types() do
      test "#{type} renders a well-formed <svg> document" do
        chart = build(unquote(type))
        svg = SVG.to_svg(chart)
        assert is_binary(svg)
        assert String.starts_with?(svg, "<svg ")
        assert String.ends_with?(svg, "</svg>")
        refute svg == ""
      end
    end
  end
end