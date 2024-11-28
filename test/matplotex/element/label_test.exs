defmodule Matplotex.Element.LabelTest do

  use Matplotex.PlotCase

  alias Matplotex.Element.Label
  alias Matplotex.Figure.Font
  describe "cast_label/2" do
    test "merging label with font" do
      font = %Font{font_size: 22}
      label = %Label{x: 1, y: 1}
      assert %Label{font_size: updated_font_size} = Label.cast_label(label, font)
      assert updated_font_size == 22
    end
  end
end
