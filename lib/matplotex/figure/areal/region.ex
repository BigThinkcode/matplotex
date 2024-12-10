defmodule Matplotex.Figure.Areal.Region do
  alias Matplotex.Figure.Areal.XyRegion.Coords
  defstruct [x: 0, y: 0, width: 0, height: 0, name: nil, theta: 0, coords: nil]

  def get_label_coords(%__MODULE__{x: x, y: y, coords: %Coords{label: {label_x, label_y}}}) do
    {x + label_x, y + label_y}
  end

  def get_tick_coords(%__MODULE__{x: x, y: y, coords: %Coords{ticks: {tick_x, tick_y}}}) do
    {x + tick_x, y + tick_y}
  end
end
