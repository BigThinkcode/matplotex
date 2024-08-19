defmodule Matplotex.Blueprint.Chart do
  alias Matplotex.Blueprint.Label
  alias Matplotex.Blueprint.Line
  @type dataset1D() :: %{x: list()}
  @type dataset2D() :: %{x: list(), y: list()}
  @type font() :: %{size: String.t(), weight: String.t(), color: String.t()}
  @type label() :: %{x: String.t() | nil, y: String.t() | nil, font: font() | nil}
  @type scale() :: %{x: number() | nil, y: number() | nil, aspect_ratio: number | nil}
  @type grid() :: %{x_scale: number() | nil, y_scale: number() | nil} | nil
  @type title() :: %{title: String.t() | nil, font_size: font() | nil}
  @type size() :: %{height: number(), width: number()} | nil
  @type tick() :: %{x_scale: number() | nil, y_scale: number() | nil, font: font()}
  @type margin() :: %{x_margin: number(), y_margin: number()} | nil
  @type valid?() :: :ok | {:error, String.t()}
  @type axis() :: :on | :off
  @type element() :: any()

  @type t() :: %__MODULE__{
          dataset: dataset1D() | dataset2D(),
          label: label(),
          scale: scale(),
          grid: grid(),
          title: title(),
          size: size(),
          tick: tick(),
          margin: margin(),
          valid?: valid(),
          axis: axis(),
          element: element(),
          type: module()
        }

  defstruct [
    :dataset,
    :label,
    :scale,
    :grid,
    :title,
    :size,
    :tick,
    :margin,
    :valid?,
    :axis,
    :element,
    :type
  ]

  @spec new(chart_params()) :: __MODULE__.t()
  def new(params), do: Map.merge(%__MODULE__{}, params)
end
