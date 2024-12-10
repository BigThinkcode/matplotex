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
      font_family = "Updated family"
      font_weight = "Updated weight"
      font_style = "Updated style"

      pt_to_inch_ratio = 1 / 60
      rc_params = %RcParams{}

      font = %Font{
        font_size: font_size,
        font_family: font_family,
        font_style: font_style,
        font_weight: font_weight,
        pt_to_inch_ratio: pt_to_inch_ratio
      }

      params = %{
        x_label_font_size: font_size,
        x_label_font_family: font_family,
        x_label_font_style: font_style,
        x_label_font_weight: font_weight,
        y_label_font_size: font_size,
        y_label_font_family: font_family,
        y_label_font_style: font_style,
        y_label_font_weight: font_weight,
        x_tick_font_size: font_size,
        x_tick_font_family: font_family,
        x_tick_font_style: font_style,
        x_tick_font_weight: font_weight,
        y_tick_font_size: font_size,
        y_tick_font_family: font_family,
        y_tick_font_style: font_style,
        y_tick_font_weight: font_weight,
        x_label_pt_to_inch_ratio: pt_to_inch_ratio,
        y_label_pt_to_inch_ratio: pt_to_inch_ratio,
        x_tick_pt_to_inch_ratio: pt_to_inch_ratio,
        y_tick_pt_to_inch_ratio: pt_to_inch_ratio
      }

      assert %RcParams{
               x_label_font: font,
               y_label_font: font,
               x_tick_font: font,
               y_tick_font: font
             } == RcParams.update_with_font(rc_params, params)
    end
  end

  test "font_associated_keys will make keys for an elemenent" do
    element = :y_label
    keys = RcParams.font_associated_keys(element)

    assert keys |> Enum.sort() ==
             [
               :y_label_dominant_baseline,
               :y_label_font_size,
               :y_label_font_family,
               :y_label_font_style,
               :y_label_font_weight,
               :y_label_fill,
               :y_label_unit_of_measurement,
               :y_label_pt_to_inch_ratio,
               :y_label_rotation,
               :y_label_flate
             ]
             |> Enum.sort()
  end
end
