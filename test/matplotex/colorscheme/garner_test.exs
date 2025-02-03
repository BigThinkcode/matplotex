defmodule Matplotex.Colorscheme.GarnerTest do
  alias Matplotex.Colorscheme.Garner
  use Matplotex.PlotCase

  describe "garn_color/3" do
    test "garn the color for specific point in the number" do
      colorset = [3,4,5,6,6,4,9]
      color = Garner.garn_color(Enum.min_max(colorset), Enum.min(colorset), "viridis")
      assert is_binary(color)
    end
  end
end
