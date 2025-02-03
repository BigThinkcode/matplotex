defmodule Matplotex.Colorscheme.Garner do
alias Matplotex.Colorscheme.Blender
alias Matplotex.InputError
alias Matplotex.Colorscheme.Colormap

  defstruct [:range, :color_cue,  :cmap, :preceeding, :minor, :major, :final]

  def garn_color({min, max} = range, point, cmap) when max != min do
    cue = (point - min) / (max - min)
    cmap
    |> fetch_from_cmap()
    |> put_range(range, cue)
    |> point_color()
  end

  defp fetch_from_cmap(cmap) do
    cmap
    |>Colormap.fetch_cmap()
    |>place_edges()
  end

  defp put_range(%__MODULE__{} = garner, range, cue) do
    %__MODULE__{garner | range: range, color_cue: cue}
  end

  defp place_edges([preceeding, minor, major,final]) do
    %__MODULE__{preceeding: preceeding, minor: minor, major: major, final: final}
  end
  defp place_edges(_) do
    raise InputError, message: "Invalid colormap"
  end

  defp point_color(%__MODULE__{color_cue: cue, preceeding: preceeding, minor: minor}) when cue < minor do
    Blender.mix(minor, preceeding, cue)
  end

  defp point_color(%__MODULE__{color_cue: cue, minor: minor, major: major}) when cue < major do
    Blender.mix(minor, major, cue)
  end

  defp point_color(%__MODULE__{color_cue: cue, major: major, final: final}) when cue >= major do
    final
  end
 end
