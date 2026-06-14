alias Matplotex.{Chart, Axis, Dataset}
alias Matplotex.Render.SVG

out = "assets"

# ── Line ─────────────────────────────────────────────────────────────────────
svg =
  Chart.new(:line)
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Month"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Sales"})
  |> Chart.add_data(Enum.zip(1..12, [3, 5, 4, 8, 7, 9, 6, 10, 8, 11, 9, 12]),
       name: "2023", color: "#4e79a7")
  |> Chart.add_data(Enum.zip(1..12, [2, 4, 6, 5, 9, 8, 7, 11, 9, 12, 10, 13]),
       name: "2024", color: "#e15759")
  |> Chart.set_title("Monthly Sales")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/line.svg", svg)
IO.puts("line.svg done")

# ── Bar ──────────────────────────────────────────────────────────────────────
svg =
  Chart.new(:bar)
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Quarter"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Revenue ($k)"})
  |> Chart.add_data([{1, 42}, {2, 58}, {3, 51}, {4, 73}], name: "Revenue", color: "#59a14f")
  |> Chart.set_title("Quarterly Revenue")
  |> Chart.set_axis_limits(:x1, 0.5, 4.5)
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/bar.svg", svg)
IO.puts("bar.svg done")

# ── Scatter ───────────────────────────────────────────────────────────────────
svg =
  Chart.new(:scatter)
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Height (cm)"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Weight (kg)"})
  |> Chart.add_data(
       [{160, 55}, {170, 65}, {175, 72}, {180, 80}, {185, 85}],
       name: "Group A", color: "#4e79a7")
  |> Chart.add_data(
       [{155, 50}, {165, 60}, {172, 68}, {178, 75}],
       name: "Group B", color: "#f28e2b")
  |> Chart.set_title("Height vs Weight")
  |> Chart.set_axis_limits(:x1, 150.0, 190.0)
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/scatter.svg", svg)
IO.puts("scatter.svg done")

# ── Area ──────────────────────────────────────────────────────────────────────
svg =
  Chart.new(:area)
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Day"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Visitors"})
  |> Chart.add_data(
       Enum.zip(1..7, [120, 180, 150, 210, 195, 240, 230]),
       name: "Unique Visitors", color: "#76b7b2")
  |> Chart.set_title("Weekly Traffic")
  |> Chart.set_axis_limits(:x1, 1.0, 7.0)
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/area.svg", svg)
IO.puts("area.svg done")

# ── Step ──────────────────────────────────────────────────────────────────────
svg =
  Chart.new(:step)
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Time"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "State"})
  |> Chart.add_data(
       [{0, 0}, {1, 1}, {2, 1}, {3, 0}, {4, 2}, {5, 2}, {6, 0}],
       name: "Signal", color: "#e15759")
  |> Chart.set_title("Signal Over Time")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/step.svg", svg)
IO.puts("step.svg done")

# ── Spline ────────────────────────────────────────────────────────────────────
svg =
  Chart.new(:spline)
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "x"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "f(x)"})
  |> Chart.add_data(
       Enum.zip(0..9, [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]),
       name: "x²", color: "#b07aa1")
  |> Chart.set_title("Smooth Curve")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/spline.svg", svg)
IO.puts("spline.svg done")

# ── Histogram ─────────────────────────────────────────────────────────────────
:rand.seed(:exsss, {1, 2, 3})
samples = for _ <- 1..500, do: :rand.normal() * 15 + 100

svg =
  Chart.new(:histogram)
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Value"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Count"})
  |> Chart.put_dataset(Dataset.from_columns(x: samples, y: samples, color: "#4e79a7"))
  |> Chart.set_title("Distribution of Values")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/histogram.svg", svg)
IO.puts("histogram.svg done")

# ── Bubble ────────────────────────────────────────────────────────────────────
ds =
  Dataset.from_columns(
    x: [1.0, 2.0, 3.0, 4.0, 5.0],
    y: [2.0, 4.0, 1.0, 5.0, 3.0],
    z: [10.0, 30.0, 15.0, 25.0, 40.0],
    name: "Products",
    color: "#76b7b2"
  )

svg =
  Chart.new(:bubble)
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Market Share"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Growth Rate"})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Product Portfolio")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/bubble.svg", svg)
IO.puts("bubble.svg done")

# ── Pie ───────────────────────────────────────────────────────────────────────
ds =
  Dataset.from_columns(
    y: [40.0, 30.0, 20.0, 10.0],
    labels: ["Organic", "Paid", "Social", "Direct"]
  )

svg =
  Chart.new(:pie)
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Traffic Sources")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/pie.svg", svg)
IO.puts("pie.svg done")

# ── Donut ─────────────────────────────────────────────────────────────────────
ds =
  Dataset.from_columns(
    y: [55.0, 25.0, 20.0],
    labels: ["Complete", "In Progress", "Not Started"]
  )

svg =
  Chart.new(:donut)
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Project Status")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/donut.svg", svg)
IO.puts("donut.svg done")

# ── Heatmap ───────────────────────────────────────────────────────────────────
:rand.seed(:exsss, {4, 5, 6})

{xs, ys, zs} =
  for(row <- 0..4, col <- 0..4, do: {col * 1.0, row * 1.0, :rand.uniform() * 100})
  |> Enum.reduce({[], [], []}, fn {x, y, z}, {xs, ys, zs} ->
    {xs ++ [x], ys ++ [y], zs ++ [z]}
  end)

ds = Dataset.from_columns(x: xs, y: ys, z: zs)

svg =
  Chart.new(:heatmap)
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Column"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Row"})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Heatmap Example")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/heatmap.svg", svg)
IO.puts("heatmap.svg done")

# ── Box Plot ──────────────────────────────────────────────────────────────────
:rand.seed(:exsss, {7, 8, 9})
group_xs = List.duplicate(1, 50) ++ List.duplicate(2, 50)

group_ys =
  Enum.map(1..50, fn _ -> :rand.normal() * 5 + 20 end) ++
    Enum.map(1..50, fn _ -> :rand.normal() * 8 + 30 end)

ds = Dataset.from_columns(x: group_xs, y: group_ys)

svg =
  Chart.new(:box)
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Group"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Value"})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Box Plot by Group")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/box.svg", svg)
IO.puts("box.svg done")

# ── Violin ────────────────────────────────────────────────────────────────────
:rand.seed(:exsss, {10, 11, 12})
group_xs = List.duplicate(1, 100) ++ List.duplicate(2, 100)

group_ys =
  Enum.map(1..100, fn _ -> :rand.normal() * 3 + 10 end) ++
    Enum.map(1..100, fn _ -> :rand.normal() * 6 + 20 end)

ds = Dataset.from_columns(x: group_xs, y: group_ys, color: "#59a14f")

svg =
  Chart.new(:violin)
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Group"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Samples"})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Violin Plot by Group")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/violin.svg", svg)
IO.puts("violin.svg done")

# ── Radar ─────────────────────────────────────────────────────────────────────
ds =
  Dataset.from_columns(
    y: [0.8, 0.6, 0.9, 0.4, 0.7, 0.85],
    labels: ["Speed", "Strength", "Agility", "Defense", "Skill", "Stamina"],
    name: "Player A",
    color: "#4e79a7"
  )

svg =
  Chart.new(:radar)
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Player Stats")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/radar.svg", svg)
IO.puts("radar.svg done")

# ── Candlestick ───────────────────────────────────────────────────────────────
times = [1, 2, 3, 4, 5]
closes = [100.0, 103.0, 101.0, 106.0, 104.0]
opens = [99.0, 100.0, 104.0, 102.0, 105.0]
highs = [104.0, 105.0, 105.0, 108.0, 107.0]
lows = [98.0, 99.0, 100.0, 101.0, 103.0]

ds =
  Dataset.from_columns(x: times, y: closes)
  |> then(fn d ->
    %{d | extra: %{
        open: Nx.tensor(opens, type: :f64),
        high: Nx.tensor(highs, type: :f64),
        low: Nx.tensor(lows, type: :f64)
      }}
  end)

svg =
  Chart.new(:candlestick)
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Time"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Price ($)"})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("AAPL — 5-Day OHLC")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/candlestick.svg", svg)
IO.puts("candlestick.svg done")

# ── Waterfall ─────────────────────────────────────────────────────────────────
svg =
  Chart.new(:waterfall)
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Category"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Amount ($k)"})
  |> Chart.add_data(
       [{1, 50}, {2, -20}, {3, 30}, {4, -10}, {5, 40}],
       name: "Cash Flow")
  |> Chart.set_title("Cash Flow Waterfall")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/waterfall.svg", svg)
IO.puts("waterfall.svg done")

# ── Funnel ────────────────────────────────────────────────────────────────────
ds =
  Dataset.from_columns(
    y: [1000.0, 750.0, 400.0, 200.0, 80.0],
    labels: ["Awareness", "Interest", "Consideration", "Intent", "Purchase"]
  )

svg =
  Chart.new(:funnel)
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Sales Funnel")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/funnel.svg", svg)
IO.puts("funnel.svg done")

IO.puts("\nAll SVGs written to #{out}/")
