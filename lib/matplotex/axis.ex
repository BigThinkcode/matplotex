defmodule Matplotex.Axis do
  @moduledoc """
  Configuration for one spatial dimension.

  `scale` holds the domain (data bounds) — set by `Chart.compile/1` from data.
  Tick pixel positions live in `Frame.tick_pixels[axis.id]`, not here.
  `tick_labels` are strings computed from the domain linspace.
  """

  @type scale_type :: :linear | :log10 | :log2 | :sqrt | :time

  @type t :: %__MODULE__{
          id: atom(),
          dimension: :x | :y | :z,
          position: :bottom | :top | :left | :right,
          label: String.t() | nil,
          tick_count: pos_integer(),
          tick_format: (number() -> String.t()) | nil,
          scale_type: scale_type(),
          scale: map() | nil,
          tick_labels: [String.t()],
          limits: {number(), number()} | nil
        }

  defstruct id: :x1,
            dimension: :x,
            position: :bottom,
            label: nil,
            tick_count: 5,
            tick_format: nil,
            scale_type: :linear,
            scale: nil,
            tick_labels: [],
            limits: nil

  @doc "Sets scale domain from an Nx tensor column. Respects `origin_at_zero`."
  def set_scale(%__MODULE__{} = axis, tensor, opts \\ []) do
    scale = Matplotex.Scale.infer_domain(tensor, opts)
    %{axis | scale: scale}
  end

  @doc """
  Computes `tick_labels` from the domain linspace.
  Pixel positions are computed separately in `Frame.compute_tick_pixels/2`.
  """
  def compute_tick_labels(%__MODULE__{scale: nil} = axis), do: axis
  def compute_tick_labels(%__MODULE__{scale: %{domain_min: nil}} = axis), do: axis

  def compute_tick_labels(%__MODULE__{scale: scale, tick_count: n, tick_format: fmt} = axis) do
    formatter = fmt || &default_format/1

    labels =
      Nx.linspace(scale.domain_min, scale.domain_max, n: n)
      |> Nx.to_list()
      |> Enum.map(formatter)

    %{axis | tick_labels: labels}
  end

  defp default_format(value) when is_float(value) do
    if Float.floor(value) == value,
      do: Integer.to_string(trunc(value)),
      else: Float.to_string(Float.round(value, 3))
  end

  defp default_format(value) when is_integer(value), do: Integer.to_string(value)
end
