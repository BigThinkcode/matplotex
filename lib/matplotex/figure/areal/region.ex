defmodule Matplotex.Figure.Areal.Region do
  alias Matplotex.Figure.Areal.XyRegion.Coords
  defstruct [:x, :y, :width, :height, :name, :theta, :coords]

  def get_label_coords(%__MODULE__{x: x, y: y, coords: %Coords{label: {label_x, label_y}}}) do
    {x + label_x, y + label_y}
  end

  def get_tick_coords(%__MODULE__{x: x, y: y, coords: %Coords{ticks: {tick_x, tick_y}}}) do
    {x + tick_x, y + tick_y}
  end
end
