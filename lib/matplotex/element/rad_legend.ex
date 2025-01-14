defmodule Matplotex.Element.RadLegend do
@moduledoc false
  alias Matplotex.Utils.Algebra
  alias Matplotex.Element.Label
  alias Matplotex.Element
  alias Matplotex.Element.Rect

  use Element

  @stroke_width 1
  @stroke "rgba(0,0,0,0)"
  @legend_size 20 / 96
  @label_type "legend.label"
  @default_opacity 1.0

  @legend_padding 5/96
  defstruct [
    :type,
    :x,
    :y,
    :color,
    :label,
    width: @legend_size,
    height: @legend_size,
    label_margin: @legend_size,
    stroke: @stroke,
    stroke_opacity: @default_opacity,
    fill_opacity: @default_opacity,
    stroke_width: @stroke_width
  ]

  @impl Element
  def assemble(legend) do
    """
    #{Rect.assemble(legend)}
    #{Element.assemble(legend.label)}
    """
  end

  def with_label(
        %__MODULE__{
          label: text,
          x: x,
          y: y,
          width: width,
          height: height
        } = legend,
        legend_font
      ) do
        {label_x, label_y} = Algebra.transform_given_point(x, y, width + @legend_padding, height/2)
    %{
      legend
      | label:
          %Label{
            x: label_x,
            y: label_y,
            text: text,
            type: @label_type
          }
          |> Label.cast_label(legend_font)
    }
  end
end
