defmodule Matplotex.Figure.RcParamTest do
  alias Matplotex.Figure.Font
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

  describe "update_with_font/2" do
    test "updates associated fonts with font_size" do
      font_size = 10
      rc_params = %RcParams{}
      font = %Font{font_size: font_size}

      params = %{
        x_label_font_size: font_size,
        y_label_font_size: font_size,
        x_tick_font_size: font_size,
        y_tick_font_size: font_size
      }

      assert %RcParams{
               x_label_font: font,
               y_label_font: font,
               x_tick_font: font,
               y_tick_font: font
             } == RcParams.update_with_font(rc_params, params)
    end
  end
end
