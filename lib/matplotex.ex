defmodule Matplotex do
  @moduledoc """
  Matplotex — a comprehensive charting library for Elixir.

  All coordinate math runs through [Nx](https://github.com/elixir-nx/nx) tensor
  operations. Every chart type implements the same three-callback behaviour; the
  compile pipeline and SVG renderer are chart-type agnostic.

  ## Installation

  Add `matplotex` to your `mix.exs` dependencies:

      def deps do
        [
          {:matplotex, "~> 0.1.0"}
        ]
      end

  ## Quick start

      alias Matplotex.{Chart, Axis, Canvas}
      alias Matplotex.Render.SVG

      Chart.new(:line, canvas: %Canvas{grid_style: :dashed, grid_color: "#c8d8e8"})
      |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Month"})
      |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left,   label: "Revenue"})
      |> Chart.add_data(Enum.zip(1..12, [3,5,4,8,7,9,6,10,8,11,9,12]), name: "2024")
      |> Chart.set_title("Monthly Revenue")
      |> Matplotex.compile()
      |> Matplotex.to_svg()
      # => "<svg>...</svg>"

  `compile/1` and `to_svg/1` are top-level delegates — you can also call them as
  `Chart.compile/1` and `SVG.to_svg/1` respectively.

  ## Compile pipeline

      Chart.new/2 → axes / data / canvas → compile/1 → to_svg/1

  Internally `compile/1` runs three ordered passes, recomputing only dirty layers:

  | Layer      | Triggered by             |
  |------------|--------------------------|
  | `:frame`   | canvas, axes, title      |
  | `:scales`  | data, frame              |
  | `:geometry`| scales, viewport, frame  |

  This makes incremental updates cheap — adding a new dataset only reruns
  `:scales` and `:geometry`, not the layout pass.

  ## Supported chart types

  Pass the atom as the first argument to `Chart.new/2`.

  | Atom           | Chart         | Key data columns           |
  |----------------|---------------|----------------------------|
  | `:line`        | Line          | x, y                       |
  | `:bar`         | Bar           | x (category index), y      |
  | `:scatter`     | Scatter       | x, y                       |
  | `:area`        | Area          | x, y                       |
  | `:step`        | Step          | x, y                       |
  | `:spline`      | Spline        | x, y                       |
  | `:histogram`   | Histogram     | x (raw samples)            |
  | `:bubble`      | Bubble        | x, y, z (point size)       |
  | `:pie`         | Pie           | y, labels                  |
  | `:donut`       | Donut         | y, labels                  |
  | `:heatmap`     | Heatmap       | x (col), y (row), z        |
  | `:box`         | Box Plot      | x (group), y (samples)     |
  | `:violin`      | Violin        | x (group), y (samples)     |
  | `:radar`       | Radar/Spider  | y (values), labels         |
  | `:candlestick` | Candlestick   | x, y (close), extra (OHLC) |
  | `:waterfall`   | Waterfall     | x, y (increments)          |
  | `:funnel`      | Funnel        | y, labels                  |

  All supported type atoms are also returned by `Matplotex.Chart.supported_types/0`.

  ## Core modules

  | Module                   | Purpose                                           |
  |--------------------------|---------------------------------------------------|
  | `Matplotex.Chart`        | Chart struct, builder API, and compile pipeline   |
  | `Matplotex.Dataset`      | Data container (`from_pairs/2`, `from_columns/1`) |
  | `Matplotex.Axis`         | Axis configuration and tick computation           |
  | `Matplotex.Canvas`       | Physical size, fonts, grid, and axis styling      |
  | `Matplotex.Viewport`     | Zoom and pan state applied during geometry pass   |
  | `Matplotex.Scale`        | Linear / log scale and data→pixel transforms      |
  | `Matplotex.Frame`        | Layout regions (plot area, margins, tick pixels)  |
  | `Matplotex.Render.SVG`   | Renders a compiled chart to an SVG string         |

  ## Adding data

  **From `{x, y}` pairs** — the simplest path:

      Chart.add_data(chart, [{1, 10}, {2, 20}, {3, 15}], name: "Series A", color: "#4e79a7")

  **From columns** — when you need a third dimension or explicit labels:

      alias Matplotex.Dataset

      ds = Dataset.from_columns(
        x:      [1.0, 2.0, 3.0],
        y:      [10.0, 20.0, 15.0],
        z:      [5.0, 8.0, 12.0],    # optional (bubble size, heatmap intensity, …)
        labels: ["A", "B", "C"],
        name:   "Series",
        color:  "#4e79a7"
      )

      Chart.put_dataset(chart, ds)

  ## Axes

      alias Matplotex.Axis

      %Axis{
        dimension:           :x,          # :x | :y | :z — which data column
        position:            :bottom,     # :bottom | :top | :left | :right
        label:               "Month",     # axis title (optional)
        tick_count:          5,           # approximate number of ticks
        tick_format:         &Float.to_string/1,  # custom tick formatter (optional)
        tick_label_rotation: :horizontal  # :horizontal | :inclined | :vertical | number
      }

  `tick_label_rotation` applies to x-axes only:

  | Value         | Angle | Best for                           |
  |---------------|-------|------------------------------------|
  | `:horizontal` | 0°    | Short labels with plenty of space  |
  | `:inclined`   | −45°  | Medium-length labels (most common) |
  | `:vertical`   | −90°  | Very long labels or many ticks     |
  | `number`      | custom| Fine-grained control (degrees)     |

  ## Canvas

      alias Matplotex.Canvas

      %Canvas{
        figsize:          {10, 6},     # width × height in inches
        dpi:              96,
        margin:           0.05,        # fraction of canvas reserved on each side
        background:       "#ffffff",   # SVG background (nil = transparent)
        title_font_size:  18,
        tick_font_size:   12,
        label_font_size:  14,
        grid_color:       "#e0e0e0",
        grid_style:       :dashed,     # :solid | :dashed | :dotted | :none
        grid_width:       1,
        axis_line_color:  "#555555",
        axis_line_width:  1.5,
        axis_line_style:  :solid,      # :solid | :dashed | :none
        origin_at_zero:   true         # force axis min to 0 when all data ≥ 0
      }

  ## Explicit axis limits

  By default domains are inferred from the data. Pin them with
  `Chart.set_axis_limits/4`:

      Chart.set_axis_limits(chart, :x1, 0.0, 15.0)
      Chart.set_axis_limits(chart, :y1, 0.0, 20.0)

  The guard `min < max` is enforced at call time; swapped values raise
  `FunctionClauseError`.

  ## Multiple series

      Chart.new(:line)
      |> Chart.add_data(Enum.zip(1..6, [1,3,2,5,4,6]), name: "Apples",  color: "#e15759")
      |> Chart.add_data(Enum.zip(1..6, [2,2,4,3,5,5]), name: "Oranges", color: "#f28e2b")
      |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
      |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
      |> Matplotex.compile()
      |> Matplotex.to_svg()

  When `color` is omitted, series are coloured automatically from a 10-color
  palette.

  ## Saving to a file

      chart
      |> Matplotex.compile()
      |> Matplotex.to_svg()
      |> then(&File.write!("chart.svg", &1))
  """

  @doc """
  Compiles the chart, recomputing only dirty layers.

  Delegates to `Matplotex.Chart.compile/1`. See that module for details on the
  dependency order and dirty-tracking semantics.
  """
  defdelegate compile(chart), to: Matplotex.Chart

  @doc """
  Renders a compiled chart to an SVG string.

  Delegates to `Matplotex.Render.SVG.to_svg/1`. The chart must have been passed
  through `compile/1` first; calling `to_svg/1` on an uncompiled chart raises.
  """
  defdelegate to_svg(chart), to: Matplotex.Render.SVG
end
