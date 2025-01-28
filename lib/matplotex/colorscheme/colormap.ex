defmodule Matplotex.Colorscheme.Colormap do
  defstruct [:color, :offset, opacity: 1]
  @dark_purple "#2A132F"
  @purple "#441E4B"
  @yellow "#fbde41"
  @red "#eb3767"
  @orange "#EEA103"
  @black "#1e1b13"
  @dark_blue "#245BC1"
  def viridis do
    [@dark_purple, @yellow]
  end

  def plasma do
    [@dark_purple, @red, @yellow]
  end

  def inferno do
    [@black, @red, @orange, @yellow]
  end

  def magma do
    [@black, @purple, @red, @yellow]
  end

  def civids do
    [@dark_blue, @yellow]
  end

  def make_colormap(colors) do
    size = length(colors)

    colors
    |> Enum.with_index()
    |> Enum.map(&colormap(&1, size))
  end

  defp colormap({index, color}, size) do
    offset = index / size / 100
    %__MODULE__{color: color, offset: offset}
  end
end
