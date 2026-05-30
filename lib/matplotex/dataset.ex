defmodule Matplotex.Dataset do
  @moduledoc """
  Columnar data for one series — Nx tensors from the moment data enters.

  All numeric columns are `Nx.Tensor` of type `:f64`.
  Non-numeric metadata (labels, categories, colors) stays in plain Elixir.

  ## Column conventions by chart type

  | Chart       | x             | y             | z (optional)   | meta             |
  |-------------|---------------|---------------|----------------|------------------|
  | line/scatter| independent   | dependent     | —              | label per point  |
  | bar         | category idx  | value         | —              | category strings |
  | histogram   | raw samples   | (computed)    | —              | —                |
  | heatmap     | x-bin         | y-bin         | intensity      | —                |
  | pie         | (ignored)     | slice values  | —              | slice labels     |
  | box/violin  | group idx     | raw samples   | —              | group labels     |
  | candlestick | time (epoch)  | (ignored)     | —              | open/high/low/close in `extra` |
  | bubble      | x             | y             | size           | label per point  |
  | radar       | (axis index)  | values        | —              | axis labels      |

  `extra` holds additional numeric columns (e.g. OHLC for candlestick) as a
  map of `%{name => Nx.tensor}`.
  """

  @type t :: %__MODULE__{
          x: Nx.Tensor.t() | nil,
          y: Nx.Tensor.t() | nil,
          z: Nx.Tensor.t() | nil,
          extra: %{atom() => Nx.Tensor.t()},
          labels: [String.t()],
          color: String.t() | nil,
          name: String.t() | nil
        }

  defstruct x: nil,
            y: nil,
            z: nil,
            extra: %{},
            labels: [],
            color: nil,
            name: nil

  @doc """
  Builds a `%Dataset{}` from a list of `{x, y}` tuples.
  Converts to `:f64` Nx tensors immediately.
  """
  def from_pairs(pairs, opts \\ []) do
    {xs, ys} = Enum.unzip(pairs)

    %__MODULE__{
      x: to_f64(xs),
      y: to_f64(ys),
      color: Keyword.get(opts, :color),
      name: Keyword.get(opts, :name),
      labels: Keyword.get(opts, :labels, [])
    }
  end

  @doc "Builds a `%Dataset{}` from keyword columns: `x: [...], y: [...], z: [...]`."
  def from_columns(opts) do
    %__MODULE__{
      x: maybe_tensor(Keyword.get(opts, :x)),
      y: maybe_tensor(Keyword.get(opts, :y)),
      z: maybe_tensor(Keyword.get(opts, :z)),
      color: Keyword.get(opts, :color),
      name: Keyword.get(opts, :name),
      labels: Keyword.get(opts, :labels, [])
    }
  end

  @doc "Returns the number of data points."
  def size(%__MODULE__{x: x}) when not is_nil(x), do: Nx.size(x)
  def size(%__MODULE__{y: y}) when not is_nil(y), do: Nx.size(y)
  def size(_), do: 0

  @doc "Returns `Nx.tensor({3, n})` of homogeneous [x; y; 1] columns."
  def to_homogeneous(%__MODULE__{x: x, y: y}) do
    n = Nx.size(x)
    ones = Nx.broadcast(Nx.tensor(1.0, type: :f64), {n})
    Nx.stack([x, y, ones])
  end

  defp to_f64(list) do
    list
    |> Enum.map(&(&1 * 1.0))
    |> Nx.tensor(type: :f64)
  end

  defp maybe_tensor(nil), do: nil
  defp maybe_tensor(list) when is_list(list), do: to_f64(list)
  defp maybe_tensor(%Nx.Tensor{} = t), do: Nx.as_type(t, :f64)
end
