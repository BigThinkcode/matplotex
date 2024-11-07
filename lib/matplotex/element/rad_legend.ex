defmodule Matplotex.Element.RadLegend do
  alias Matplotex.Element.Label
  alias Matplotex.Element

  use Element

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


  @impl Element
  def assemble(legend) do
      """
      #{Element.assemble(legend.rect)}
      #{Element.assemble(legend.label)}
      """
  end

  @impl Element
  def flipy(%__MODULE__{y: y} = legend, height) do
    %__MODULE__{legend | y: height - y}
  end
end
