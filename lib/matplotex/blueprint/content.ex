defmodule Matplotex.Blueprint.Content do
  @type t :: %__MODULE__{
          width: number(),
          height: number(),
          x: number(),
          y: number(),
          u_margin: number(),
          u_width: number(),
          tick_length: number(),
          components: list(),
          x_max: number(),
          y_max: number()
        }
  defstruct [
    :width,
    :height,
    :x,
    :y,
    :u_margin,
    :u_width,
    :tick_length,
    :components,
    :x_max,
    :y_max
  ]

  def new(params), do: Map.merge(%__MODULE__{}, params)
end
