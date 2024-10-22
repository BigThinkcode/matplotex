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

  describe "cast_xticks/1" do
    test "add element for tick in axes", %{figure: figure} do
      assert %Figure{axes: %{element: elements, tick: %{x: x_ticks, y: y_ticks}}} =
               figure
               |> Lead.set_spines()
               |> Cast.cast_xticks()

      assert Enum.filter(elements, fn x -> x.type == "figure.x_tick" end) |> length() ==
               length(x_ticks)
    end

    test "generates the ticks are getting confined within the limit", %{figure: figure} do
      figure = Matplotex.set_xlim(figure, {2, 6})

      %Figure{axes: %{element: elements}} =
        figure
        |> Lead.set_spines()
        |> Cast.cast_xticks()

      assert Enum.filter(elements, fn x -> x.type == "figure.x_tick" end) |> length() == 5
    end

    test "ticks will get generated if no ticks added" do
      x = [1, 3, 7, 4, 2, 5, 6]
      y = [1, 3, 7, 4, 2, 5, 6]
      figure = Matplotex.plot(x, y)

      %Figure{axes: %{data: {x, _y}, tick: %{x: x_ticks}, element: elements}} =
        figure
        |> Lead.set_spines()
        |> Cast.cast_xticks()

      assert Enum.filter(elements, fn x -> x.type == "figure.x_tick" end) |> length() ==
               length(x_ticks)
    end
  end

  describe "cast_yticks/1" do
    test "add element for tick in axes", %{figure: figure} do
      assert %Figure{axes: %{element: elements, tick: %{y: y_ticks}}} =
               figure
               |> Lead.set_spines()
               |> Cast.cast_yticks()

      assert Enum.filter(elements, fn x -> x.type == "figure.y_tick" end) |> length() ==
               length(y_ticks)
    end
  end

  # TODO: Testcases for show and hide hgrid
  describe "cast_hgrids/1" do
    test "add elements for horizontal grids", %{figure: figure} do
      assert %Figure{axes: %{element: elements, tick: %{y: y_ticks}}} =
               figure
               |> Lead.set_spines()
               |> Cast.cast_label()
               |> Cast.cast_xticks()
               |> Cast.cast_yticks()
               |> Cast.cast_hgrids()

      assert Enum.filter(elements, fn x -> x.type == "figure.h_grid" end) |> length() ==
               length(y_ticks)
    end
  end

  describe "cast_vgrids/1" do
    test "add elements for vertical grids", %{figure: figure} do
      assert %Figure{axes: %{element: elements, tick: %{x: x_ticks}}} =
               figure
               |> Lead.set_spines()
               |> Cast.cast_label()
               |> Cast.cast_xticks()
               |> Cast.cast_yticks()
               |> Cast.cast_hgrids()
               |> Cast.cast_vgrids()

      assert Enum.filter(elements, fn x -> x.type == "figure.v_grid" end) |> length() ==
               length(x_ticks)
    end
  end
end
