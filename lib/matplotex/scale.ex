defmodule Matplotex.Scale do
  @moduledoc """
  Homogeneous 3×3 transform matrices for 2D coordinate mapping.

  Every spatial operation — data→pixel, y-flip, zoom, pan, log scale —
  is a 3×3 matrix.  Any composition of N operations is still just one
  matrix (computed via `Nx.dot`), so applying it to n data points costs
  exactly one `Nx.dot` regardless of composition depth.

  ## Coordinate spaces

      data space       → [domain_min, domain_max] per axis
      normalized space → [0.0, 1.0] × [0.0, 1.0]
      pixel space      → [plot_x, plot_x+plot_w] × [plot_y, plot_y+plot_h]

  ## Compose order (rightmost applied first)

      final = pixel_matrix · viewport_matrix · normalize_matrix

  The full pipeline per series is one `Nx.dot(final, homogeneous_points)`.
  """

  @f64 :f64

  # ── Elementary matrices ───────────────────────────────────────────────────

  @doc """
  3×3 translation matrix.

      [1  0  tx]
      [0  1  ty]
      [0  0   1]
  """
  def translate(tx, ty) do
    Nx.tensor([[1, 0, tx], [0, 1, ty], [0, 0, 1]], type: @f64)
  end

  @doc """
  3×3 scale matrix.

      [sx  0   0]
      [ 0  sy  0]
      [ 0   0  1]

  Pass negative `sy` to flip the y-axis (SVG y-down convention).
  """
  def scale(sx, sy) do
    Nx.tensor([[sx, 0, 0], [0, sy, 0], [0, 0, 1]], type: @f64)
  end

  @doc "3×3 identity matrix."
  def identity(), do: Nx.eye(3, type: @f64)

  @doc "Composes two matrices: `Nx.dot(a, b)` — `b` is applied first."
  def compose(a, b), do: Nx.dot(a, b)

  @doc "Composes a list of matrices left-to-right (rightmost applied first to points)."
  def compose_all([m | rest]), do: Enum.reduce(rest, m, &Nx.dot(&2, &1))

  # ── Scale types ───────────────────────────────────────────────────────────

  @doc """
  Linear scale: maps `[domain_min, domain_max]` → `[range_min, range_max]`.
  Returns a 3×3 matrix (only x or y component set; the other is identity).
  """
  def linear(domain_min, domain_max, range_min, range_max, axis) do
    span_d = domain_max - domain_min
    span_r = range_max - range_min
    s = span_r / span_d
    t = range_min - domain_min * s

    case axis do
      :x -> translate(t, 0) |> compose(scale(s, 1))
      :y -> translate(0, t) |> compose(scale(1, s))
    end
  end

  @doc """
  Log scale (base 10): maps `[log10(domain_min), log10(domain_max)]` → range.
  Data must be positive.
  """
  def log10(domain_min, domain_max, range_min, range_max, axis) do
    linear(:math.log10(domain_min), :math.log10(domain_max), range_min, range_max, axis)
  end

  @doc """
  Y-flip matrix: flips the y-axis so that domain_min maps to the bottom of
  the plot region (SVG y=0 is at the top).

  Equivalent to reflecting around y = (range_min + range_max) / 2.
  """
  def y_flip(range_min, range_max) do
    mid = (range_min + range_max) / 2.0
    translate(0, mid) |> compose(scale(1, -1)) |> compose(translate(0, -mid))
  end

  # ── Full data→pixel transforms ────────────────────────────────────────────

  @doc """
  Builds the full data→pixel transform for one `{x_axis, y_axis}` pair.

  Compose order:
    normalize_x · normalize_y · y_flip · scale_to_plot · viewport

  All operations are Nx matrix multiplications.
  """
  def data_to_pixel(x_scale, y_scale, plot, viewport_matrix \\ nil) do
    plot_x = Nx.to_number(plot[0])
    plot_y = Nx.to_number(plot[1])
    plot_w = Nx.to_number(plot[2])
    plot_h = Nx.to_number(plot[3])

    # 1. Normalize x: domain → [0, 1]
    norm_x = linear(x_scale.domain_min, x_scale.domain_max, 0.0, 1.0, :x)

    # 2. Normalize y: domain → [0, 1]
    norm_y = linear(y_scale.domain_min, y_scale.domain_max, 0.0, 1.0, :y)

    # 3. Viewport (zoom/pan in normalized space)
    vp = viewport_matrix || identity()

    # 4. Scale normalized [0,1]² → plot pixel region, with y-flip
    to_pixel =
      compose_all([
        translate(plot_x, plot_y + plot_h),
        scale(plot_w, -plot_h)
      ])

    compose_all([to_pixel, vp, norm_y, norm_x])
  end

  @doc """
  Applies a 3×3 transform to homogeneous points.

      points: Nx.tensor shape {3, n}
      returns: Nx.tensor shape {2, n}  (x and y pixel rows, homogeneous row dropped)
  """
  def apply(transform, points_3xn) do
    result = Nx.dot(transform, points_3xn)
    result[0..1]
  end

  # ── Axis scale struct ─────────────────────────────────────────────────────

  @doc "Returns a scale descriptor struct."
  def axis_scale(domain_min, domain_max, type \\ :linear) do
    %{domain_min: domain_min * 1.0, domain_max: domain_max * 1.0, type: type}
  end

  @doc """
  Infers the domain from an Nx tensor column.
  Respects `origin_at_zero`: if all values are positive, min is forced to 0.
  """
  def infer_domain(tensor, opts \\ []) do
    origin_at_zero = Keyword.get(opts, :origin_at_zero, true)

    data_min = tensor |> Nx.reduce_min() |> Nx.to_number()
    data_max = tensor |> Nx.reduce_max() |> Nx.to_number()

    domain_min =
      if data_min > 0 && origin_at_zero, do: 0.0, else: data_min * 1.0

    %{domain_min: domain_min, domain_max: data_max * 1.0, type: :linear}
  end
end
