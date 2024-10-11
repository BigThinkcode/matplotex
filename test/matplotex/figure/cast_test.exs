defmodule Matplotex.Figure.CastTest do
  alias Matplotex.Figure
  alias Matplotex.Figure.Cast
  alias Matplotex.Figure.Lead
  use Matplotex.PlotCase

  setup do
    figure = Matplotex.FrameHelpers.sample_figure() |> Lead.set_spines()
    {:ok, %{figure: figure}}
  end

  describe "cast_spines" do
    test "add elements for borders in axes", %{figure: figure} do
      assert %Figure{axes: %{element: elements}} = Cast.cast_spines(figure)

      assert Enum.filter(elements, fn x -> x.type == "spine.top" end) |> length() == 1
      assert Enum.filter(elements, fn x -> x.type == "spine.bottom" end) |> length() == 1
      assert Enum.filter(elements, fn x -> x.type == "spine.right" end) |> length() == 1
      assert Enum.filter(elements, fn x -> x.type == "spine.left" end) |> length() == 1
    end
  end

  describe "cast_title" do
    test "add element for title in axes", %{figure: figure} do
      assert %Figure{axes: %{element: elements}} =
               figure
               |> Lead.set_spines()
               |> Cast.cast_spines()
               |> Cast.cast_title()

      assert Enum.filter(elements, fn x -> x.type == "figure.title" end) |> length == 1
      end
  end
  describe "cast_label/1" do
    test "add element for label in axes", %{figure: figure} do
      assert %Figure{axes: %{element: elements}} =
               figure
               |> Lead.set_spines()
               |> Cast.cast_label()
      assert Enum.filter(elements, fn x -> x.type == "figure.x_label" end) |> length() == 1
      assert Enum.filter(elements, fn x -> x.type == "figure.y_label" end) |> length() == 1
    end
  end
  describe "cast_ticks/1" do
    test "add element for tick in axes", %{figure: figure} do
      assert %Figure{axes: %{element: elements}, tick: %{x: x_ticks, y: y_ticks}} =
               figure
               |> Lead.set_spines()
               |> Cast.cast_ticks()
      assert Enum.filter(elements, fn x -> x.type == "figure.x_tick" end) |> length() == length(x_ticks)
      assert Enum.filter(elements, fn x -> x.type == "figure.y_tick" end) |> length() == length(y_ticks)
    end
  end
end
