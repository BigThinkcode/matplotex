defmodule Matplotex.Element.Label do
  @type word() :: String.t()
  @type t() :: %__MODULE__{
          type: String.t(),
          x: number(),
          y: number(),
          font_size: word(),
          font_weight: word(),
          text: word(),
          fill: word(),
          font_family: word(),
          font_style: word(),
          dominant_baseline: word()
        }
  defstruct [
    :type,
    :x,
    :y,
    :font_size,
    :font_weight,
    :text,
    :fill,
    :font_family,
    :font_style,
    :dominant_baseline
  ]
end
