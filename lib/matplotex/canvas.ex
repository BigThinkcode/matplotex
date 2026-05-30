defmodule Matplotex.Canvas do
  @moduledoc """
  Physical dimensions of the chart surface.

  All sizes are in inches; `dpi` converts to pixels.
  `margin` is the fraction of canvas to reserve on each side before
  any axis strips are placed.
  """

  @type t :: %__MODULE__{
          figsize: {number(), number()},
          dpi: number(),
          margin: float(),
          background: String.t() | nil,
          title_font_size: number(),
          tick_font_size: number(),
          label_font_size: number(),
          grid_color: String.t(),
          origin_at_zero: boolean()
        }

  defstruct figsize: {8, 5},
            dpi: 96,
            margin: 0.05,
            background: nil,
            title_font_size: 18,
            tick_font_size: 12,
            label_font_size: 14,
            grid_color: "#e0e0e0",
            origin_at_zero: true

  @doc "Returns `{width_px, height_px}` as plain floats."
  def to_pixels(%__MODULE__{figsize: {w, h}, dpi: dpi}) do
    {w * dpi * 1.0, h * dpi * 1.0}
  end
end
