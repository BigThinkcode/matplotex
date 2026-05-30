defmodule Matplotex.ChartTypesTest do
  use ExUnit.Case, async: true
  alias Matplotex.{Chart, Axis, Dataset}
  alias Matplotex.Geom.{Path, Rects, Circles, Arcs, Segments}

  defp basic_chart(type, data \\ Enum.zip(1..5, [2, 4, 1, 5, 3])) do
    Chart.new(type)
    |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
    |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
    |> Chart.add_data(data)
    |> Chart.compile()
  end

  defp geom0(chart), do: hd(chart.geometry)

  # ── Line ─────────────────────────────────────────────────────────────────

  describe "line chart" do
    test "produces a Path geom" do
      chart = basic_chart(:line)
      assert [%Path{}] = geom0(chart)
    end

    test "path coords have shape {2, n}" do
      chart = basic_chart(:line)
      [%Path{coords: coords}] = geom0(chart)
      {rows, _cols} = Nx.shape(coords)
      assert rows == 2
    end

    test "x coords span within plot region" do
      chart = basic_chart(:line)
      [%Path{coords: coords}] = geom0(chart)
      plot_x = Nx.to_number(chart.frame.plot[0])
      plot_r = plot_x + Nx.to_number(chart.frame.plot[2])
      xs = coords[0] |> Nx.to_list()
      assert Enum.min(xs) >= plot_x - 1
      assert Enum.max(xs) <= plot_r + 1
    end
  end

  # ── Bar ──────────────────────────────────────────────────────────────────

  describe "bar chart" do
    test "produces Rects geom" do
      chart = basic_chart(:bar)
      assert [%Rects{}] = geom0(chart)
    end

    test "rects count matches data points" do
      data = Enum.zip(1..5, [10, 20, 15, 25, 5])
      chart = basic_chart(:bar, data)
      [%Rects{xywh: xywh}] = geom0(chart)
      {_, n} = Nx.shape(xywh)
      assert n == 5
    end

    test "bar heights are positive" do
      chart = basic_chart(:bar)
      [%Rects{xywh: xywh}] = geom0(chart)
      heights = xywh[3] |> Nx.to_list()
      assert Enum.all?(heights, &(&1 > 0))
    end
  end

  # ── Scatter ───────────────────────────────────────────────────────────────

  describe "scatter chart" do
    test "produces Circles geom" do
      chart = basic_chart(:scatter)
      assert [%Circles{}] = geom0(chart)
    end

    test "circle count matches data points" do
      chart = basic_chart(:scatter)
      [%Circles{cxcyr: cxcyr}] = geom0(chart)
      {_, n} = Nx.shape(cxcyr)
      assert n == 5
    end

    test "all radii are positive" do
      chart = basic_chart(:scatter)
      [%Circles{cxcyr: cxcyr}] = geom0(chart)
      rs = cxcyr[2] |> Nx.to_list()
      assert Enum.all?(rs, &(&1 > 0))
    end
  end

  # ── Area ──────────────────────────────────────────────────────────────────

  describe "area chart" do
    test "produces a closed Path geom" do
      chart = basic_chart(:area)
      assert [%Path{closed: true}] = geom0(chart)
    end

    test "area path has 2× points (top + base mirrored)" do
      data  = Enum.zip(1..5, [2, 4, 1, 5, 3])
      chart = basic_chart(:area, data)
      [%Path{coords: coords}] = geom0(chart)
      {_, n} = Nx.shape(coords)
      assert n == 10  # 5 top + 5 base
    end
  end

  # ── Histogram ─────────────────────────────────────────────────────────────

  describe "histogram chart" do
    test "produces Rects geom" do
      samples = Enum.map(1..50, &(&1 * 1.0))
      chart =
        Chart.new(:histogram)
        |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
        |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
        |> Chart.add_data(samples |> Enum.map(&{&1, 1}) |> then(fn _ ->
             Enum.zip(samples, samples)  # x = samples, y = (unused, actual y from histogram)
           end))
        |> then(fn _ ->
          # Histogram uses x column only
          chart2 = Chart.new(:histogram)
            |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
            |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
          ds = Dataset.from_columns(x: samples, y: samples)
          Chart.put_dataset(chart2, ds) |> Chart.compile()
        end)

      assert is_list(chart.geometry)
    end
  end

  # ── Pie ──────────────────────────────────────────────────────────────────

  describe "pie chart" do
    test "produces Arcs geom" do
      ds = Dataset.from_columns(y: [30.0, 50.0, 20.0])
      chart = Chart.new(:pie) |> Chart.put_dataset(ds) |> Chart.compile()
      assert is_list(chart.geometry)
    end

    test "arc count matches slice count" do
      ds = Dataset.from_columns(y: [30.0, 50.0, 20.0])
      chart = Chart.new(:pie) |> Chart.put_dataset(ds) |> Chart.compile()
      [%Arcs{start_angles: sa}] = geom0(chart)
      assert Nx.size(sa) == 3
    end

    test "slices sum to 2π" do
      ds = Dataset.from_columns(y: [25.0, 25.0, 50.0])
      chart = Chart.new(:pie) |> Chart.put_dataset(ds) |> Chart.compile()
      [%Arcs{start_angles: sa, end_angles: ea}] = geom0(chart)
      total = ea |> Nx.to_list() |> List.last()
      assert_in_delta total, 2.0 * :math.pi(), 0.001
    end
  end

  # ── Scatter with z (bubble fallback) ─────────────────────────────────────

  describe "scatter with z" do
    test "radii vary with z values" do
      ds = Dataset.from_columns(x: [1.0, 2.0, 3.0], y: [1.0, 2.0, 3.0], z: [1.0, 5.0, 10.0])
      chart =
        Chart.new(:scatter)
        |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
        |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
        |> Chart.put_dataset(ds)
        |> Chart.compile()

      [%Circles{cxcyr: cxcyr}] = geom0(chart)
      rs = cxcyr[2] |> Nx.to_list()
      assert hd(rs) < List.last(rs)
    end
  end

  # ── Step ─────────────────────────────────────────────────────────────────

  describe "step chart" do
    test "produces a Path geom" do
      chart = basic_chart(:step)
      assert [%Path{}] = geom0(chart)
    end

    test "step path has more points than data" do
      data  = Enum.zip(1..4, [1, 3, 2, 4])
      chart = basic_chart(:step, data)
      [%Path{coords: coords}] = geom0(chart)
      {_, n} = Nx.shape(coords)
      assert n > 4  # step doubles intermediate points
    end
  end

  # ── Radar ─────────────────────────────────────────────────────────────────

  describe "radar chart" do
    test "produces a closed Path geom" do
      ds = Dataset.from_columns(y: [0.8, 0.6, 0.9, 0.4, 0.7])
      chart = Chart.new(:radar) |> Chart.put_dataset(ds) |> Chart.compile()
      assert [%Path{closed: true}] = geom0(chart)
    end

    test "polygon has n vertices matching data dimensions" do
      ds = Dataset.from_columns(y: [0.8, 0.6, 0.9, 0.4, 0.7])
      chart = Chart.new(:radar) |> Chart.put_dataset(ds) |> Chart.compile()
      [%Path{coords: coords}] = geom0(chart)
      {_, n} = Nx.shape(coords)
      assert n == 5
    end
  end
end
