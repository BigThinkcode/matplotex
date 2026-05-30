defmodule Matplotex.Geom do
  @moduledoc """
  Typed geometry structs — all coordinates as Nx tensors, no SVG strings.

  The renderer module converts these to SVG at the final boundary.
  This separation means the same geometry can target SVG, Canvas, or
  WebGL without changing the chart computation layer.

  ## Shape types

  | Struct         | Tensor field(s)              | SVG output         |
  |----------------|------------------------------|--------------------|
  | `Path`         | `coords {2, n}`              | `<path d=.../>`    |
  | `Rects`        | `xywh {4, n}`                | `<rect .../>`      |
  | `Circles`      | `cxcyr {3, n}`               | `<circle .../>`    |
  | `Arcs`         | `angles {2, n}`, `radii {n}` | `<path d=.../>`    |
  | `Segments`     | `x1y1x2y2 {4, n}`            | `<line .../>`      |
  | `Polygons`     | list of `coords {2, n}`      | `<polygon .../>`   |
  | `Heatmap`      | `xywh {4, n}`, `values {n}`  | `<rect fill=.../>`  |
  | `Text`         | `xy {2, n}`, `labels [str]`  | `<text .../>`      |
  """

  defmodule Path do
    @moduledoc "Open or closed polyline / spline path."
    @type t :: %__MODULE__{
            coords: Nx.Tensor.t(),
            closed: boolean(),
            stroke: String.t(),
            fill: String.t(),
            stroke_width: number(),
            stroke_dasharray: String.t() | nil,
            opacity: float()
          }
    defstruct coords: nil,
              closed: false,
              stroke: "#4e79a7",
              fill: "none",
              stroke_width: 2,
              stroke_dasharray: nil,
              opacity: 1.0,
              svg_path_d: nil
  end

  defmodule Rects do
    @moduledoc "Batch of rectangles (bars, heatmap cells)."
    @type t :: %__MODULE__{
            xywh: Nx.Tensor.t(),
            fills: [String.t()] | String.t(),
            stroke: String.t() | nil,
            opacity: float()
          }
    defstruct xywh: nil,
              fills: "#4e79a7",
              stroke: nil,
              opacity: 1.0
  end

  defmodule Circles do
    @moduledoc "Batch of circles (scatter, bubble)."
    @type t :: %__MODULE__{
            cxcyr: Nx.Tensor.t(),
            fills: [String.t()] | String.t(),
            stroke: String.t() | nil,
            opacity: float()
          }
    defstruct cxcyr: nil,
              fills: "#4e79a7",
              stroke: nil,
              opacity: 0.8
  end

  defmodule Arcs do
    @moduledoc "Batch of SVG arcs (pie/donut slices)."
    @type t :: %__MODULE__{
            center: {float(), float()},
            outer_radius: float(),
            inner_radius: float(),
            start_angles: Nx.Tensor.t(),
            end_angles: Nx.Tensor.t(),
            fills: [String.t()],
            stroke: String.t(),
            stroke_width: number()
          }
    defstruct center: {0.0, 0.0},
              outer_radius: 0.0,
              inner_radius: 0.0,
              start_angles: nil,
              end_angles: nil,
              fills: [],
              stroke: "white",
              stroke_width: 1
  end

  defmodule Segments do
    @moduledoc "Batch of line segments (axis ticks, candlestick wicks, error bars)."
    @type t :: %__MODULE__{
            x1y1x2y2: Nx.Tensor.t(),
            stroke: String.t(),
            stroke_width: number(),
            stroke_dasharray: String.t() | nil
          }
    defstruct x1y1x2y2: nil,
              stroke: "#555555",
              stroke_width: 1,
              stroke_dasharray: nil
  end

  defmodule Heatmap do
    @moduledoc "Grid of colored cells — values mapped through a color scale."
    @type t :: %__MODULE__{
            xywh: Nx.Tensor.t(),
            values: Nx.Tensor.t(),
            colorscale: atom(),
            v_min: float(),
            v_max: float(),
            opacity: float()
          }
    defstruct xywh: nil,
              values: nil,
              colorscale: :viridis,
              v_min: 0.0,
              v_max: 1.0,
              opacity: 1.0
  end

  defmodule TextLabels do
    @moduledoc "Batch of text annotations."
    @type t :: %__MODULE__{
            xy: Nx.Tensor.t(),
            labels: [String.t()],
            font_size: number(),
            anchor: String.t(),
            fill: String.t()
          }
    defstruct xy: nil,
              labels: [],
              font_size: 12,
              anchor: "middle",
              fill: "#333333"
  end
end
