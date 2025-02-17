defmodule Matplotex.Colorscheme.GarnerTest do
  alias Matplotex.Colorscheme.Colormap
  alias Matplotex.Colorscheme.Garner
  use Matplotex.PlotCase

  describe "garn_color/3" do
    test "garn the color for specific point in the number" do
      colorset = [3, 4, 5, 6, 6, 4, 9]
      viridis = Colormap.fetch_cmap(:viridis)
      color = Garner.garn_color(Enum.min_max(colorset), Enum.min(colorset), viridis)
      assert is_color(color)
    end
  end

  defp is_color("#" <> <<_r::binary-size(2), _g::binary-size(2), _b::binary-size(2)>>), do: true
  defp is_color(_), do: false
end
