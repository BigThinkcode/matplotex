defmodule Matplotex.PieChart.Legend do
  alias Matplotex.Element.Label

  @stroke_width 1
  @stroke "rgba(0,0,0,0)"
  @legend_size 20
  @label_type "legend.label"
  defstruct [
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

  def generate_label(
        %__MODULE__{label: text, x: x, y: y, width: width, label_margin: label_margin} = legend
      ) do
    %{legend | label: %Label{x: x + width + label_margin, y: y, text: text, type: @label_type}}
  end
end
