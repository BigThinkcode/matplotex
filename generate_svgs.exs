alias Matplotex.{Chart, Axis, Dataset, Canvas}
alias Matplotex.Render.SVG

out = "assets"

# ── Line — dashed grid, thick colored axis spine ──────────────────────────────
svg =
  Chart.new(:line,
    canvas: %Canvas{
      grid_style: :dashed,
      grid_color: "#c8d8e8",
      grid_width: 1,
      axis_line_color: "#4a6fa5",
      axis_line_width: 2.0,
      axis_line_style: :solid
    }
  )
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

# ── Bar — solid grid, standard dark axis ─────────────────────────────────────
svg =
  Chart.new(:bar,
    canvas: %Canvas{
      grid_style: :solid,
      grid_color: "#d4d4d4",
      grid_width: 1,
      axis_line_color: "#333333",
      axis_line_width: 1.5,
      axis_line_style: :solid
    }
  )
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Quarter"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Revenue ($k)"})
  |> Chart.add_data([{1, 42}, {2, 58}, {3, 51}, {4, 73}], name: "Revenue", color: "#59a14f")
  |> Chart.set_title("Quarterly Revenue")
  |> Chart.set_axis_limits(:x1, 0.5, 4.5)
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/bar.svg", svg)
IO.puts("bar.svg done")

# ── Scatter — dotted grid, red accent axis ────────────────────────────────────
svg =
  Chart.new(:scatter,
    canvas: %Canvas{
      grid_style: :dotted,
      grid_color: "#cccccc",
      grid_width: 1,
      axis_line_color: "#e15759",
      axis_line_width: 2.0,
      axis_line_style: :solid
    }
  )
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

# ── Area — dashed grid, teal axis, no background ─────────────────────────────
svg =
  Chart.new(:area,
    canvas: %Canvas{
      grid_style: :dashed,
      grid_color: "#b2dfdb",
      grid_width: 1.5,
      axis_line_color: "#00796b",
      axis_line_width: 2.0,
      axis_line_style: :solid
    }
  )
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

# ── Step — no grid, bold solid axis ──────────────────────────────────────────
svg =
  Chart.new(:step,
    canvas: %Canvas{
      grid_style: :none,
      axis_line_color: "#222222",
      axis_line_width: 2.5,
      axis_line_style: :solid
    }
  )
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

# ── Spline — dotted fine grid, purple axis ────────────────────────────────────
svg =
  Chart.new(:spline,
    canvas: %Canvas{
      grid_style: :dotted,
      grid_color: "#ddd8f0",
      grid_width: 1,
      axis_line_color: "#b07aa1",
      axis_line_width: 2.0,
      axis_line_style: :solid
    }
  )
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

# ── Histogram — solid light grid, default axis ────────────────────────────────
:rand.seed(:exsss, {1, 2, 3})
samples = for _ <- 1..500, do: :rand.normal() * 15 + 100

svg =
  Chart.new(:histogram,
    canvas: %Canvas{
      grid_style: :solid,
      grid_color: "#e8e8e8",
      grid_width: 1,
      axis_line_color: "#555555",
      axis_line_width: 1.5,
      axis_line_style: :solid
    }
  )
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Value"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Count"})
  |> Chart.put_dataset(Dataset.from_columns(x: samples, y: samples, color: "#4e79a7"))
  |> Chart.set_title("Distribution of Values")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/histogram.svg", svg)
IO.puts("histogram.svg done")

# ── Bubble — dashed grid, teal axis ──────────────────────────────────────────
ds =
  Dataset.from_columns(
    x: [1.0, 2.0, 3.0, 4.0, 5.0],
    y: [2.0, 4.0, 1.0, 5.0, 3.0],
    z: [10.0, 30.0, 15.0, 25.0, 40.0],
    name: "Products",
    color: "#76b7b2"
  )

svg =
  Chart.new(:bubble,
    canvas: %Canvas{
      grid_style: :dashed,
      grid_color: "#b2e0dc",
      grid_width: 1,
      axis_line_color: "#76b7b2",
      axis_line_width: 2.0,
      axis_line_style: :solid
    }
  )
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Market Share"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Growth Rate"})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Product Portfolio")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/bubble.svg", svg)
IO.puts("bubble.svg done")

# ── Pie — no grid (no cartesian axes) ────────────────────────────────────────
ds =
  Dataset.from_columns(
    y: [40.0, 30.0, 20.0, 10.0],
    labels: ["Organic", "Paid", "Social", "Direct"]
  )

svg =
  Chart.new(:pie, canvas: %Canvas{grid_style: :none, axis_line_style: :none})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Traffic Sources")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/pie.svg", svg)
IO.puts("pie.svg done")

# ── Donut — no grid ───────────────────────────────────────────────────────────
ds =
  Dataset.from_columns(
    y: [55.0, 25.0, 20.0],
    labels: ["Complete", "In Progress", "Not Started"]
  )

svg =
  Chart.new(:donut, canvas: %Canvas{grid_style: :none, axis_line_style: :none})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Project Status")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/donut.svg", svg)
IO.puts("donut.svg done")

# ── Heatmap — solid grid, dark axis ──────────────────────────────────────────
:rand.seed(:exsss, {4, 5, 6})

{xs, ys, zs} =
  for(row <- 0..4, col <- 0..4, do: {col * 1.0, row * 1.0, :rand.uniform() * 100})
  |> Enum.reduce({[], [], []}, fn {x, y, z}, {xs, ys, zs} ->
    {xs ++ [x], ys ++ [y], zs ++ [z]}
  end)

ds = Dataset.from_columns(x: xs, y: ys, z: zs)

svg =
  Chart.new(:heatmap,
    canvas: %Canvas{
      grid_style: :solid,
      grid_color: "#999999",
      grid_width: 1.5,
      axis_line_color: "#222222",
      axis_line_width: 2.0,
      axis_line_style: :solid
    }
  )
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Column"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Row"})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Heatmap Example")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/heatmap.svg", svg)
IO.puts("heatmap.svg done")

# ── Box Plot — dashed grid, default axis ─────────────────────────────────────
:rand.seed(:exsss, {7, 8, 9})
group_xs = List.duplicate(1, 50) ++ List.duplicate(2, 50)

group_ys =
  Enum.map(1..50, fn _ -> :rand.normal() * 5 + 20 end) ++
    Enum.map(1..50, fn _ -> :rand.normal() * 8 + 30 end)

ds = Dataset.from_columns(x: group_xs, y: group_ys)

svg =
  Chart.new(:box,
    canvas: %Canvas{
      grid_style: :dashed,
      grid_color: "#e0e0e0",
      grid_width: 1,
      axis_line_color: "#555555",
      axis_line_width: 1.5,
      axis_line_style: :solid
    }
  )
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Group"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Value"})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Box Plot by Group")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/box.svg", svg)
IO.puts("box.svg done")

# ── Violin — dotted grid, green axis ─────────────────────────────────────────
:rand.seed(:exsss, {10, 11, 12})
group_xs = List.duplicate(1, 100) ++ List.duplicate(2, 100)

group_ys =
  Enum.map(1..100, fn _ -> :rand.normal() * 3 + 10 end) ++
    Enum.map(1..100, fn _ -> :rand.normal() * 6 + 20 end)

ds = Dataset.from_columns(x: group_xs, y: group_ys, color: "#59a14f")

svg =
  Chart.new(:violin,
    canvas: %Canvas{
      grid_style: :dotted,
      grid_color: "#c8e6c9",
      grid_width: 1,
      axis_line_color: "#388e3c",
      axis_line_width: 2.0,
      axis_line_style: :solid
    }
  )
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Group"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Samples"})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Violin Plot by Group")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/violin.svg", svg)
IO.puts("violin.svg done")

# ── Radar — no grid (uses its own polar grid), no axis spine ─────────────────
ds =
  Dataset.from_columns(
    y: [0.8, 0.6, 0.9, 0.4, 0.7, 0.85],
    labels: ["Speed", "Strength", "Agility", "Defense", "Skill", "Stamina"],
    name: "Player A",
    color: "#4e79a7"
  )

svg =
  Chart.new(:radar, canvas: %Canvas{grid_style: :none, axis_line_style: :none})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Player Stats")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/radar.svg", svg)
IO.puts("radar.svg done")

# ── Candlestick — solid fine grid, bold dark axis ─────────────────────────────
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
  Chart.new(:candlestick,
    canvas: %Canvas{
      grid_style: :solid,
      grid_color: "#eeeeee",
      grid_width: 1,
      axis_line_color: "#111111",
      axis_line_width: 2.0,
      axis_line_style: :solid
    }
  )
  |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Time"})
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Price ($)"})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("AAPL — 5-Day OHLC")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/candlestick.svg", svg)
IO.puts("candlestick.svg done")

# ── Waterfall — dashed grid, orange accent axis ───────────────────────────────
svg =
  Chart.new(:waterfall,
    canvas: %Canvas{
      grid_style: :dashed,
      grid_color: "#ffe0cc",
      grid_width: 1,
      axis_line_color: "#f28e2b",
      axis_line_width: 2.0,
      axis_line_style: :solid
    }
  )
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

# ── Funnel — no grid, no axis (shape chart) ───────────────────────────────────
ds =
  Dataset.from_columns(
    y: [1000.0, 750.0, 400.0, 200.0, 80.0],
    labels: ["Awareness", "Interest", "Consideration", "Intent", "Purchase"]
  )

svg =
  Chart.new(:funnel, canvas: %Canvas{grid_style: :none, axis_line_style: :none})
  |> Chart.put_dataset(ds)
  |> Chart.set_title("Sales Funnel")
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/funnel.svg", svg)
IO.puts("funnel.svg done")

# ── Tick Label Rotation — inclined (−45°), monthly bar ───────────────────────
months = ~w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]

svg =
  Chart.new(:bar,
    canvas: %Canvas{
      grid_style: :dashed,
      grid_color: "#c8d8e8",
      grid_width: 1,
      axis_line_color: "#4a6fa5",
      axis_line_width: 1.5,
      axis_line_style: :solid
    }
  )
  |> Chart.put_axis(:x1, %Axis{
       dimension: :x, position: :bottom, label: "Month",
       tick_count: 12,
       tick_format: fn x -> Enum.at(months, round(x) - 1) end,
       tick_label_rotation: :inclined
     })
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Sales"})
  |> Chart.add_data(
       Enum.zip(1..12, [42, 38, 55, 61, 49, 70, 65, 80, 74, 68, 77, 90]),
       name: "2024", color: "#4e79a7")
  |> Chart.set_title("Monthly Sales — Inclined Labels")
  |> Chart.set_axis_limits(:x1, 1.0, 12.0)
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/tick_inclined.svg", svg)
IO.puts("tick_inclined.svg done")

# ── Tick Label Rotation — vertical (−90°), long product names ─────────────────
products = ["Product Alpha", "Product Beta", "Product Gamma", "Product Delta", "Product Epsilon"]

svg =
  Chart.new(:bar,
    canvas: %Canvas{
      grid_style: :solid,
      grid_color: "#e0e0e0",
      grid_width: 1,
      axis_line_color: "#555555",
      axis_line_width: 1.5,
      axis_line_style: :solid
    }
  )
  |> Chart.put_axis(:x1, %Axis{
       dimension: :x, position: :bottom,
       tick_count: 5,
       tick_format: fn x -> Enum.at(products, round(x) - 1) end,
       tick_label_rotation: :vertical
     })
  |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left, label: "Units Sold"})
  |> Chart.add_data(
       Enum.zip(1..5, [120, 95, 142, 88, 110]),
       name: "Q3", color: "#59a14f")
  |> Chart.set_title("Sales by Product — Vertical Labels")
  |> Chart.set_axis_limits(:x1, 1.0, 5.0)
  |> Chart.compile()
  |> SVG.to_svg()
File.write!("#{out}/tick_vertical.svg", svg)
IO.puts("tick_vertical.svg done")

IO.puts("\nAll SVGs written to #{out}/")
