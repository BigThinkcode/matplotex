defmodule Matplotex.Colorscheme.Colormap do
  @moduledoc false
  defstruct [:color, :offset, opacity: 1]

  def viridis do
    ["#FDE725","#6CCE59","#1F9E89", "#482777"]
  end

  def plasma do
    ["#F7E425", "#ED6925", "#9C179E", "#0C0786"]
  end

  def inferno do
    ["#FCFFA4", "#F56C3E", "#B12A90", "#000004"]
  end

  def magma do
    ["#FCFDBF", "#FB8861", "#B73779", "#000004"]
  end

  def fetch_cmap(cmap) when is_binary(cmap), do: cmap |> String.to_atom() |> fetch_cmap()

  def fetch_cmap(cmap) do
    apply(__MODULE__, cmap, []) |> make_colormap()
  end

  def make_colormap(colors) do
    size = length(colors)
   offsets =  Nx.linspace(0, 1, n: size)|> Nx.to_list()
    colors
    |> Enum.zip(offsets)
    |> Enum.map(&colormap(&1))
  end

  def default_cmap(), do: viridis()

  defp colormap({color, offset}) do
    %__MODULE__{color: color, offset: offset}
  end
end
