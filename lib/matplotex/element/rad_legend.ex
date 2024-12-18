defmodule Matplotex.Element.RadLegend do
  alias Matplotex.Element.Label
  alias Matplotex.Element
  alias Matplotex.Element.Rect

  use Element

  @stroke_width 1
  @stroke "rgba(0,0,0,0)"
  @legend_size 20 / 96
  @label_type "legend.label"
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
    stroke_width: @stroke_width
  ]

  @impl Element
  def assemble(legend) do
    """
    #{Rect.assemble(legend)}
    #{Element.assemble(legend.label)}
    """
  end

  @impl Element
  def flipy(%__MODULE__{y: y} = legend, height) do
    %__MODULE__{legend | y: height - y, label: Label.flipy(legend.label, height)}
  end

  def with_label(
        %__MODULE__{
          label: text,
          x: x,
          y: y,
          width: width,
          height: height
        } = legend, legend_font
      ) do

    %{
      legend
      | label: %Label{
          x: x + width ,
          y: y + height / 2,
          text: text,
          type: @label_type
        }
        |> Label.cast_label(legend_font)
    }
  end
end
