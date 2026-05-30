defmodule Matplotex.Chart.Behaviour do
  @moduledoc """
  Behaviour that every chart type module must implement.

  Adding a new chart type = one module, three callbacks.
  The engine (Chart, Frame, Renderer) never changes.
  """

  @doc """
  Optional statistical pre-processing in data space.

  Called before coordinate mapping. Use for: binning (histogram),
  KDE estimation (violin), OHLC grouping (candlestick), etc.

  Default implementation returns the dataset unchanged.
  """
  @callback stat_transform(dataset :: Matplotex.Dataset.t(), opts :: map()) ::
              Matplotex.Dataset.t()

  @doc """
  Converts a dataset to geometry structs.

  `transform` is the precomputed 3×3 data→pixel matrix (may be nil for
  chart types that don't use linear axes, e.g. pie).

  `frame` gives access to `frame.plot` for chart types that need
  the plot region directly (e.g. pie center/radius).

  Returns a list of `%Geom.*{}` structs.
  """
  @callback to_geometry(
              dataset :: Matplotex.Dataset.t(),
              transform :: Nx.Tensor.t() | nil,
              frame :: Matplotex.Frame.t()
            ) :: [struct()]

  @doc """
  Declares the default axes for this chart type.

  Called when the user doesn't specify axes — provides sensible defaults.
  """
  @callback default_axes() :: [{atom(), Matplotex.Axis.t()}]

  @optional_callbacks stat_transform: 2, default_axes: 0
end
