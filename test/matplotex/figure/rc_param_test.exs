defmodule Matplotex.Figure.RcParamTest do
  use Matplotex.PlotCase
  alias Matplotex.Figure.RcParams
  alias Matplotex.Figure

  setup do
    x = [1, 3, 7, 4, 2, 5, 6]
    y = [1, 3, 7, 4, 2, 5, 6]

    figure = Matplotex.plot(x, y)
    {:ok, %{figure: figure}}
  end

  describe "get_rc/2" do
    test "retrieve values ", %{figure: figure} do
      figure = Figure.set_rc_params(figure, x_label_font_size: 14, y_label_font_size: 13)
      assert RcParams.get_rc(figure.rc_params, :get_x_label_font_size) == 14
      assert RcParams.get_rc(figure.rc_params, :get_y_label_font_size) == 13
    end
  end
end
