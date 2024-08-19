defmodule Matplotex.Blueprint.Chart do
  alias Matplotex.Blueprint.Label
  alias Matplotex.Blueprint.Line
  @type dataset() :: %{x: list(), y: list()}
  @type labels() :: [Label.t()] | map()
  @type lines() :: [Line.t()]
  @type word() :: String.t()
  @type label_prefix() :: %{x: String.t(), y: String.t()}
  @type label_offset() :: %{x: number(), y: number()}
  @type chart_params() :: %{
          color_palette: list(),
          dataset: dataset(),
          height: number(),
          labels: map(),
          label_offset: number(),
          label_prefix: map(),
          margin: number(),
          type: module(),
          width: number(),
          y_max: number(),
          y_scale: number()
        }
  @type t() :: %__MODULE__{
          axis_lines: list(),
          content: any(),
          color_palette: list(),
          dataset: dataset(),
          elements: any(),
          errors: list(),
          grid_lines: lines(),
          height: float(),
          label_offset: label_offset(),
          label_prefix: label_prefix(),
          labels: labels(),
          show_axis: boolean(),
          show_grid_lines: boolean(),
          margin: float(),
          type: atom(),
          valid?: boolean(),
          width: number(),
          x_max: number(),
          x_scale: number(),
          y_max: number(),
          y_scale: number()
        }

  defstruct [
    :axis_lines,
    :content,
    :color_palette,
    :dataset,
    :elements,
    :errors,
    :grid_lines,
    :height,
    :label_offset,
    :label_prefix,
    :labels,
    :margin,
    :show_axis,
    :show_grid_lines,
    :type,
    :valid?,
    :width,
    :x_max,
    :x_scale,
    :y_max,
    :y_scale
  ]

  @spec new(chart_params()) :: __MODULE__.t()
  def new(params), do: Map.merge(%__MODULE__{}, params)
end
