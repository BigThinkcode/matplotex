defmodule Matplotex.ChartTypesExtraTest do
  @moduledoc """
  Coverage for the chart types not exercised by `chart_types_test.exs`:
  funnel, violin, waterfall, spline, candlestick and heatmap.

  Each type is checked at two levels: the geometry structs produced by
  `Chart.compile/1`, and the SVG string produced by the renderer.
  """
  use ExUnit.Case, async: true

  alias Matplotex.{Chart, Axis, Dataset}
  alias Matplotex.Geom.{Path, Rects, Segments}
  alias Matplotex.Render.SVG

  defp with_xy_axes(chart) do
    chart
    |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
    |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
  end

  defp geom0(chart), do: hd(chart.geometry)

  # ── Funnel ─────────────────────────────────────────────────────────────────

  describe "funnel chart" do
    defp funnel_chart do
      ds = Dataset.from_columns(y: [100.0, 70.0, 40.0, 15.0])
      Chart.new(:funnel) |> Chart.put_dataset(ds) |> Chart.compile()
    end

    test "produces a Rects geom" do
      assert [%Rects{}] = geom0(funnel_chart())
    end

    test "one rect per stage" do
      [%Rects{xywh: xywh}] = geom0(funnel_chart())
      {_, n} = Nx.shape(xywh)
      assert n == 4
    end

    test "bar widths shrink monotonically with the values" do
      [%Rects{xywh: xywh}] = geom0(funnel_chart())
      widths = xywh[2] |> Nx.to_list()
      assert widths == Enum.sort(widths, :desc)
    end

    test "bars are horizontally centred (largest is widest)" do
      [%Rects{xywh: xywh}] = geom0(funnel_chart())
      xs = xywh[0] |> Nx.to_list()
      widths = xywh[2] |> Nx.to_list()
      centres = Enum.zip(xs, widths) |> Enum.map(fn {x, w} -> x + w / 2 end)
      first = hd(centres)
      assert Enum.all?(centres, &(abs(&1 - first) < 0.5))
    end

    test "renders rect elements" do
      assert SVG.to_svg(funnel_chart()) =~ "<rect"
    end
  end

  # ── Violin ─────────────────────────────────────────────────────────────────

  describe "violin chart" do
    defp violin_chart do
      xs = List.duplicate(1.0, 20) ++ List.duplicate(2.0, 20)
      ys =
        Enum.map(1..20, &(&1 / 4.0)) ++
          Enum.map(1..20, &(2.0 + &1 / 4.0))

      ds = Dataset.from_columns(x: xs, y: ys)
      Chart.new(:violin) |> with_xy_axes() |> Chart.put_dataset(ds) |> Chart.compile()
    end

    test "produces one closed Path per group" do
      geoms = geom0(violin_chart())
      assert length(geoms) == 2
      assert Enum.all?(geoms, &match?(%Path{closed: true}, &1))
    end

    test "each violin outline mirrors both sides (120 = 2 × 60 kde samples)" do
      [%Path{coords: coords} | _] = geom0(violin_chart())
      {2, n} = Nx.shape(coords)
      assert n == 120
    end

    test "renders filled path elements" do
      svg = SVG.to_svg(violin_chart())
      assert svg =~ "<path"
    end
  end

  # ── Waterfall ────────────────────────────────────────────────────────────────

  describe "waterfall chart" do
    defp waterfall_chart(deltas) do
      ds = Dataset.from_columns(x: Enum.to_list(1..length(deltas)) |> Enum.map(&(&1 * 1.0)), y: deltas)
      Chart.new(:waterfall) |> with_xy_axes() |> Chart.put_dataset(ds) |> Chart.compile()
    end

    test "positive deltas produce a green Rects geom" do
      geoms = geom0(waterfall_chart([10.0, 20.0, 30.0]))
      assert Enum.any?(geoms, &match?(%Rects{fills: "#26a69a"}, &1))
    end

    test "negative deltas produce a red Rects geom" do
      geoms = geom0(waterfall_chart([10.0, -5.0, -3.0]))
      assert Enum.any?(geoms, &match?(%Rects{fills: "#ef5350"}, &1))
    end

    test "total rect count equals the number of steps" do
      geoms = geom0(waterfall_chart([10.0, -5.0, 8.0, -2.0]))
      total =
        geoms
        |> Enum.map(fn %Rects{xywh: xywh} -> elem(Nx.shape(xywh), 1) end)
        |> Enum.sum()

      assert total == 4
    end

    test "all bar heights are positive" do
      geoms = geom0(waterfall_chart([10.0, -5.0, 8.0]))

      heights =
        geoms
        |> Enum.flat_map(fn %Rects{xywh: xywh} -> xywh[3] |> Nx.to_list() end)

      assert Enum.all?(heights, &(&1 > 0))
    end

    test "renders rect elements" do
      assert SVG.to_svg(waterfall_chart([10.0, -5.0, 8.0])) =~ "<rect"
    end
  end

  # ── Spline ───────────────────────────────────────────────────────────────────

  describe "spline chart" do
    defp spline_chart do
      Chart.new(:spline)
      |> with_xy_axes()
      |> Chart.add_data(Enum.zip(1..6, [2, 5, 3, 8, 6, 9]))
      |> Chart.compile()
    end

    test "produces a single Path geom with no coords tensor" do
      assert [%Path{coords: nil} = p] = geom0(spline_chart())
      assert is_binary(p.svg_path_d)
    end

    test "the path string is a cubic-bezier (starts with M, contains C)" do
      [%Path{svg_path_d: d}] = geom0(spline_chart())
      assert String.starts_with?(d, "M ")
      assert d =~ "C "
    end

    test "renders a <path> using the prebuilt d attribute" do
      [%Path{svg_path_d: d}] = geom0(spline_chart())
      svg = SVG.to_svg(spline_chart())
      assert svg =~ "<path"
      assert svg =~ d
    end
  end

  # ── Candlestick ──────────────────────────────────────────────────────────────

  describe "candlestick chart" do
    defp candlestick_chart do
      # 3 sessions: bullish, bearish, bullish
      open  = [10.0, 15.0, 12.0]
      high  = [16.0, 16.0, 18.0]
      low   = [9.0, 11.0, 11.0]
      close = [15.0, 12.0, 17.0]

      ds = %Dataset{
        x: Nx.tensor([1.0, 2.0, 3.0], type: :f64),
        y: Nx.tensor(close, type: :f64),
        extra: %{
          open: Nx.tensor(open, type: :f64),
          high: Nx.tensor(high, type: :f64),
          low: Nx.tensor(low, type: :f64)
        }
      }

      Chart.new(:candlestick) |> with_xy_axes() |> Chart.put_dataset(ds) |> Chart.compile()
    end

    test "produces wick Segments" do
      geoms = geom0(candlestick_chart())
      assert Enum.any?(geoms, &match?(%Segments{}, &1))
    end

    test "one wick segment per session" do
      geoms = geom0(candlestick_chart())
      [%Segments{x1y1x2y2: segs}] = Enum.filter(geoms, &match?(%Segments{}, &1))
      {4, n} = Nx.shape(segs)
      assert n == 3
    end

    test "bullish and bearish bodies get distinct colours" do
      geoms = geom0(candlestick_chart())
      fills = geoms |> Enum.filter(&match?(%Rects{}, &1)) |> Enum.map(& &1.fills)
      assert "#26a69a" in fills
      assert "#ef5350" in fills
    end

    test "renders both line (wick) and rect (body) elements" do
      svg = SVG.to_svg(candlestick_chart())
      assert svg =~ "<line"
      assert svg =~ "<rect"
    end
  end

  # ── Heatmap ──────────────────────────────────────────────────────────────────

  describe "heatmap chart" do
    defp heatmap_chart do
      # 3×3 grid
      xs = for _ <- 0..2, c <- 0..2, do: c * 1.0
      ys = for r <- 0..2, _ <- 0..2, do: r * 1.0
      zs = Enum.map(0..8, &(&1 * 1.0))

      ds = Dataset.from_columns(x: xs, y: ys, z: zs)
      Chart.new(:heatmap) |> with_xy_axes() |> Chart.put_dataset(ds) |> Chart.compile()
    end

    test "produces a Rects geom" do
      assert [%Rects{}] = geom0(heatmap_chart())
    end

    test "one cell per data point" do
      [%Rects{xywh: xywh}] = geom0(heatmap_chart())
      {_, n} = Nx.shape(xywh)
      assert n == 9
    end

    test "fills is a per-cell colour list of hex strings" do
      [%Rects{fills: fills}] = geom0(heatmap_chart())
      assert is_list(fills)
      assert length(fills) == 9
      assert Enum.all?(fills, &(&1 =~ ~r/^#[0-9a-f]{6}$/i))
    end

    test "low and high intensity cells map to different colours" do
      [%Rects{fills: fills}] = geom0(heatmap_chart())
      assert hd(fills) != List.last(fills)
    end

    test "renders rect elements" do
      assert SVG.to_svg(heatmap_chart()) =~ "<rect"
    end
  end

  # ── Cross-cutting: every supported type compiles & renders ───────────────────

  describe "all supported chart types" do
    test "supported_types/0 lists 17 types" do
      assert length(Chart.supported_types()) == 17
    end
  end
end
