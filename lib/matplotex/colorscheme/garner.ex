defmodule Matplotex.Colorscheme.Garner do
  @moduledoc false
  alias Matplotex.Colorscheme.Rgb
  alias Matplotex.Colorscheme.Blender
  alias Matplotex.InputError

  defstruct [:range, :color_cue, :cmap, :preceeding, :minor, :major, :final]

  def garn_color({min, max} = range, point, cmap) when max != min do
    cue = (point - min) / (max - min)

    cmap
    |> make_from_cmap()
    |> put_range(range, cue)
    |> point_color()
  end

  defp make_from_cmap(cmap) do
    cmap
    |> to_rgb()
    |> place_edges()
  end

  defp put_range(%__MODULE__{} = garner, range, cue) do
    %__MODULE__{garner | range: range, color_cue: cue}
  end

  defp to_rgb(color_map) do
    Enum.map(color_map, &Rgb.from_cmap!(&1))
  end

  defp place_edges([preceeding, minor, major, final]) do
    %__MODULE__{
      preceeding: {preceeding.color, preceeding.offset},
      minor: {minor.color, minor.offset},
      major: {major.color, major.offset},
      final: {final.color, final.offset}
    }
  end

  defp place_edges(_) do
    raise InputError, message: "Invalid colormap"
  end

  defp point_color(%__MODULE__{
         color_cue: cue,
         preceeding: {preceeding, preceeding_offset},
         minor: {minor, minor_offset}
       })
       when cue <= minor_offset do
    cue = mix_perces(cue, preceeding_offset, minor_offset)
    minor |> Blender.mix(preceeding, cue) |> Rgb.to_string()
  end

  defp point_color(%__MODULE__{
         color_cue: cue,
         minor: {minor, minor_offset},
         major: {major, major_offset}
       })
       when cue <= major_offset do
    cue = mix_perces(cue, minor_offset, major_offset)
    major |> Blender.mix(minor, cue) |> Rgb.to_string()
  end

  defp point_color(%__MODULE__{
         color_cue: cue,
         major: {major, major_offset},
         final: {final, final_offset}
       })
       when cue > major_offset do
    cue = mix_perces(cue, major_offset, final_offset)
    final |> Blender.mix(major, cue) |> Rgb.to_string()
  end

  defp mix_perces(cue, preceeding, postceeding) when preceeding != postceeding do
    (cue - preceeding) / (postceeding - preceeding)
  end

  defp mix_perces(cue, _, _), do: cue
end
