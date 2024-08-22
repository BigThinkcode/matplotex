defmodule Matplotex.BarChart.Content do
  @type color_palette() :: list() | String.t()
  @type t :: %__MODULE__{
          width: number(),
          height: number(),
          x: number(),
          y: number(),
          u_margin: number(),
          u_width: number(),
          tick_length: number(),
          x_max: number(),
          y_max: number(),
          label_offset: number(),
          label_suffix: String.t(),
          color_palette: color_palette()
        }

  @type ordinate :: {atom(), integer()}
  defstruct [
    :width,
    :height,
    :x,
    :y,
    :u_margin,
    :u_width,
    :tick_length,
    :x_max,
    :y_max,
   :label_offset,
    :label_suffix,
    :color_palette
  ]

  def new(params), do: Map.merge(%__MODULE__{}, params)
  @spec transform(ordinate(), __MODULE__.t()) :: number()
  def transform({:x, x}, %__MODULE__{x: cx, u_margin: u_margin}), do: x + cx + u_margin
  def transform({:y, y}, %__MODULE__{y: cy}), do: y - cy

  @spec bar_height(number(), __MODULE__.t()) :: number()
  def bar_height(y, %__MODULE__{height: cheight}), do: cheight - y
  @spec x_axis_tick(number(), __MODULE__.t()) :: float()
  def x_axis_tick(x, %__MODULE__{u_width: u_width, u_margin: u_margin, x: cx}),
    do: x + cx + u_margin + u_width / 2
end
