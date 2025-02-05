defmodule Matplotex.Colorscheme.Garner do
alias Matplotex.Colorscheme.Rgb
alias Matplotex.Colorscheme.Blender
alias Matplotex.InputError

  defstruct [:range, :color_cue,  :cmap, :preceeding, :minor, :major, :final]

  def garn_color({min, max} = range, point, cmap) when max != min do
    cue = (point - min) / (max - min)
    cmap
    |> make_from_cmap()
    |> put_range(range, cue)
    |> point_color()
  end

  defp make_from_cmap(cmap) do
    cmap
    |>to_rgb()
    |>place_edges()
  end

  defp put_range(%__MODULE__{} = garner, range, cue) do
    %__MODULE__{garner | range: range, color_cue: cue}
  end

  defp to_rgb(color_map) do
    Enum.map(color_map, &Rgb.from_cmap!(&1))
  end

  defp place_edges([preceeding, minor, major,final]) do
    %__MODULE__{preceeding: preceeding.color, minor: minor.color, major: major.color, final: final.color}
  end
  defp place_edges(_) do
    raise InputError, message: "Invalid colormap"
  end

  defp point_color(%__MODULE__{color_cue: cue, preceeding: preceeding, minor: minor}) when cue < minor do
   minor|> Blender.mix(preceeding, cue)|> Rgb.to_string()
  end

  defp point_color(%__MODULE__{color_cue: cue, minor: minor, major: major}) when cue < major do
   major|> Blender.mix(minor, cue)|> Rgb.to_string()
  end

  defp point_color(%__MODULE__{color_cue: cue, major: major, final: final}) when cue >= major do
    final|> Blender.mix(major)|> Rgb.to_string()
  end
 end
