defmodule Matplotex.Colorscheme.Colormap do
@moduledoc false
  defstruct [:color, :offset, opacity: 1]
  def viridis do
    ["#fde725","#21918c","#3b528b","#440154"]
  end

  def plasma do
    ["#F7E425","#ED6925", "#9C179E", "#0C0786" ]
  end

  def inferno do
    ["#FCFFA4","#F56C3E","#B12A90","#000004"]
  end

  def magma do
    ["#FCFDBF","#FB8861", "#B73779", "#000004"]
  end

  def fetch_cmap(cmap) when is_binary(cmap), do: cmap |> String.to_atom() |> fetch_cmap()

  def fetch_cmap(cmap) do
    apply(__MODULE__, cmap, []) |> make_colormap()
  end
  def make_colormap(colors) do
    size = length(colors)
    colors
    |> Enum.with_index()
    |> Enum.map(&colormap(&1, size))
  end

  def default_cmap(), do: viridis()

  defp colormap({color, idx}, size) do
    offset = idx / size * 100
    %__MODULE__{color: color, offset: offset}
  end


end
