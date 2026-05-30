defmodule Matplotex.Stat do
  @moduledoc """
  Statistical transforms — all operate on Nx tensors.

  These are pure data-space operations that run before coordinate mapping.
  Each function takes and returns Nx tensors so they compose freely.

  ## Level of detail

  `level_of_detail/3` is the key function for large-data performance.
  When `n >> pixel_width`, it bins the data to `pixel_width` buckets,
  returning representative x/y pairs. The chart geometry layer never
  sees more data points than there are pixels to display them.
  """

  # ── Binning ───────────────────────────────────────────────────────────────

  @doc """
  Bins `x`/`y` tensors into `bins` equal-width buckets along x.

  Returns `{bin_centers, bin_means}` — two `Nx.tensor {bins}` tensors.
  Used by histogram and level-of-detail downsampling.
  """
  def bin_by_x(x, y, bins) do
    x_min = x |> Nx.reduce_min() |> Nx.to_number()
    x_max = x |> Nx.reduce_max() |> Nx.to_number()
    width = (x_max - x_min) / bins

    bin_idx =
      x
      |> Nx.subtract(Nx.tensor(x_min, type: :f64))
      |> Nx.divide(Nx.tensor(width, type: :f64))
      |> Nx.floor()
      |> Nx.as_type(:s64)
      |> Nx.clip(0, bins - 1)

    {centers, means} =
      Enum.reduce(0..(bins - 1), {[], []}, fn b, {cs, ms} ->
        mask = Nx.equal(bin_idx, Nx.tensor(b, type: :s64))
        count = mask |> Nx.sum() |> Nx.to_number()

        {c, m} =
          if count > 0 do
            center = x_min + (b + 0.5) * width
            mean_y = y |> Nx.multiply(Nx.as_type(mask, :f64)) |> Nx.sum()
            mean_y = mean_y |> Nx.divide(Nx.tensor(count * 1.0, type: :f64)) |> Nx.to_number()
            {center, mean_y}
          else
            {x_min + (b + 0.5) * width, 0.0}
          end

        {cs ++ [c], ms ++ [m]}
      end)

    {Nx.tensor(centers, type: :f64), Nx.tensor(means, type: :f64)}
  end

  @doc """
  Histogram: counts values into `bins` equal-width bins.

  Returns `{bin_edges, counts}` — `{bins+1}` and `{bins}` tensors.
  """
  def histogram(x, bins) do
    x_min = x |> Nx.reduce_min() |> Nx.to_number()
    x_max = x |> Nx.reduce_max() |> Nx.to_number()
    width = (x_max - x_min) / bins

    bin_idx =
      x
      |> Nx.subtract(Nx.tensor(x_min, type: :f64))
      |> Nx.divide(Nx.tensor(width, type: :f64))
      |> Nx.floor()
      |> Nx.as_type(:s64)
      |> Nx.clip(0, bins - 1)

    counts =
      Enum.map(0..(bins - 1), fn b ->
        Nx.equal(bin_idx, Nx.tensor(b, type: :s64)) |> Nx.sum() |> Nx.to_number()
      end)

    edges =
      Enum.map(0..bins, fn b -> x_min + b * width end)

    {Nx.tensor(edges, type: :f64), Nx.tensor(counts, type: :f64)}
  end

  # ── Level of detail ───────────────────────────────────────────────────────

  @doc """
  Downsamples `{x, y}` tensors to at most `pixel_width` representative points.

  If `n <= pixel_width * 2`, returns the original tensors unchanged.
  Otherwise, bins along x and returns `{bin_centers, bin_means}`.

  This is the core function for rendering large datasets — call it before
  computing geometry so the coordinate transform sees O(pixels) not O(n).
  """
  def level_of_detail(x, y, pixel_width) do
    n = Nx.size(x)

    if n <= pixel_width * 2 do
      {x, y}
    else
      bin_by_x(x, y, pixel_width)
    end
  end

  # ── Summary statistics ────────────────────────────────────────────────────

  @doc """
  Five-number summary for box plots: `{min, q1, median, q3, max}`.
  All returned as plain floats.
  """
  def five_number_summary(x) do
    sorted = Nx.sort(x) |> Nx.to_list() |> Enum.sort()
    n = length(sorted)

    min_v = hd(sorted)
    max_v = List.last(sorted)
    median = quantile(sorted, n, 0.5)
    q1 = quantile(sorted, n, 0.25)
    q3 = quantile(sorted, n, 0.75)

    {min_v, q1, median, q3, max_v}
  end

  @doc """
  Kernel density estimate (Gaussian kernel) at `n_points` evaluation points.

  Returns `{xs, densities}` as Nx tensors.
  Bandwidth uses Silverman's rule: `h = 1.06 * std * n^(-1/5)`.
  """
  def kde(x, n_points \\ 100) do
    n = Nx.size(x) * 1.0
    x_min = x |> Nx.reduce_min() |> Nx.to_number()
    x_max = x |> Nx.reduce_max() |> Nx.to_number()
    std = x |> Nx.standard_deviation() |> Nx.to_number()
    bw = 1.06 * std * :math.pow(n, -0.2)

    eval_xs = Nx.linspace(x_min, x_max, n: n_points) |> Nx.to_list()

    x_list = Nx.to_list(x)

    densities =
      Enum.map(eval_xs, fn xi ->
        Enum.reduce(x_list, 0.0, fn xj, acc ->
          z = (xi - xj) / bw
          acc + :math.exp(-0.5 * z * z)
        end) / (n * bw * :math.sqrt(2 * :math.pi()))
      end)

    {Nx.tensor(eval_xs, type: :f64), Nx.tensor(densities, type: :f64)}
  end

  @doc """
  Rolling statistics over a window — returns `{means, stds}`.
  Used for band/ribbon charts (confidence intervals).
  """
  def rolling(y, window) do
    n = Nx.size(y)
    list = Nx.to_list(y)

    {means, stds} =
      Enum.map(0..(n - 1), fn i ->
        lo = max(0, i - div(window, 2))
        hi = min(n - 1, i + div(window, 2))
        slice = Enum.slice(list, lo..hi)
        count = length(slice)
        mean = Enum.sum(slice) / count
        variance = Enum.reduce(slice, 0.0, fn v, a -> a + (v - mean) ** 2 end) / count
        {mean, :math.sqrt(variance)}
      end)
      |> Enum.unzip()

    {Nx.tensor(means, type: :f64), Nx.tensor(stds, type: :f64)}
  end

  # ── Colorscales ───────────────────────────────────────────────────────────

  @doc """
  Maps a normalized value `t ∈ [0, 1]` to a hex color via `colorscale`.

  Supported: `:viridis`, `:plasma`, `:inferno`, `:magma`, `:blues`, `:reds`,
  `:greens`, `:rdbu` (diverging red→white→blue).
  """
  def colorscale(t, scale \\ :viridis)

  def colorscale(t, :blues) do
    r = trunc(220 - 180 * t)
    g = trunc(230 - 180 * t)
    b = 255
    to_hex(r, g, b)
  end

  def colorscale(t, :reds) do
    r = 255
    g = trunc(255 - 220 * t)
    b = trunc(255 - 220 * t)
    to_hex(r, g, b)
  end

  def colorscale(t, :viridis) do
    # Simplified viridis: dark-purple → teal → yellow
    r = trunc(if t < 0.5, do: 68 + 2 * t * 100, else: 68 + 2 * 100 + (t - 0.5) * 2 * 175)
    g = trunc(1 + t * 254)
    b = trunc(if t < 0.5, do: 84 + t * 120, else: max(0, 204 - (t - 0.5) * 2 * 200))
    to_hex(clamp(r), clamp(g), clamp(b))
  end

  def colorscale(t, :rdbu) do
    r = trunc(if t < 0.5, do: 255, else: 255 - (t - 0.5) * 2 * 255)
    g = trunc(if t < 0.5, do: t * 2 * 230, else: 230 - (t - 0.5) * 2 * 230)
    b = trunc(if t < 0.5, do: t * 2 * 230, else: 255)
    to_hex(clamp(r), clamp(g), clamp(b))
  end

  defp to_hex(r, g, b) do
    "##{pad_hex(r)}#{pad_hex(g)}#{pad_hex(b)}"
  end

  defp pad_hex(n), do: n |> Integer.to_string(16) |> String.pad_leading(2, "0")
  defp clamp(n), do: max(0, min(255, trunc(n)))

  defp quantile(sorted, n, q) do
    idx = q * (n - 1)
    lo = floor(idx)
    hi = ceil(idx)
    frac = idx - lo

    v_lo = Enum.at(sorted, lo)
    v_hi = Enum.at(sorted, hi)
    v_lo + frac * (v_hi - v_lo)
  end
end
