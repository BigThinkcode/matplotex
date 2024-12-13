defmodule Matplotex.Figure.CastTest do
  alias Matplotex.Figure
  alias Matplotex.Figure.Cast
  alias Matplotex.Figure.Lead
  use Matplotex.PlotCase

  setup do
    figure = Matplotex.FrameHelpers.sample_figure()
    {:ok, %{figure: figure}}
  end


  describe "cast_spines_by_region/1" do
    test "add elements for borders in axes", %{figure: figure} do
      figure = Lead.set_regions_areal(figure)
      assert %Figure{axes: %{element: elements}} = Cast.cast_spines_by_region(figure)

      assert Enum.any?(elements, fn x -> x.type == "spine.top" end)
      assert Enum.any?(elements, fn x -> x.type == "spine.bottom" end)
      assert Enum.any?(elements, fn x -> x.type == "spine.right" end)
      assert Enum.any?(elements, fn x -> x.type == "spine.left" end)
    end
  end

  describe "cast_title_by_region/1" do
    test "add element for title in axes", %{figure: figure} do
      assert %Figure{axes: %{element: elements}} =
               figure
               |> Lead.set_regions_areal()
               |> Cast.cast_spines_by_region()
               |> Cast.cast_title_by_region()

      assert Enum.any?(elements, fn x -> x.type == "figure.title" end)
    end
  end

  describe "cast_label_by_region/1" do
    test "add element for label in axes", %{figure: figure} do
      assert %Figure{axes: %{element: elements}} =
               figure
               |> Lead.set_regions_areal()
               |> Cast.cast_label_by_region()

      assert Enum.any?(elements, fn x -> x.type == "figure.x_label" end)
      assert Enum.any?(elements, fn x -> x.type == "figure.y_label" end)
    end
  end

  describe "cast_xticks_by_region/1" do
    test "add element for tick in axes", %{figure: figure} do
      assert %Figure{axes: %{element: elements, tick: %{x: x_ticks, y: _y_ticks}}} =
               figure
               |> Lead.set_regions_areal()
               |> Cast.cast_xticks_by_region()

      assert Enum.filter(elements, fn x -> x.type == "figure.x_tick" end) |> length() ==
               length(x_ticks)
    end
  end

  describe "cast_yticks_by_region/1" do
    test "add element for tick in axes", %{figure: figure} do
      assert %Figure{axes: %{element: elements, tick: %{y: y_ticks}}} =
               figure
               |> Lead.set_regions_areal()
               |> Cast.cast_yticks_by_region()

      assert Enum.filter(elements, fn x -> x.type == "figure.y_tick" end) |> length() ==
               length(y_ticks)
    end
  end

  # TODO: Testcases for show and hide hgrid

  describe "cast_hgrids_by_region/1" do
    test "add elements for horizontal grids", %{figure: figure} do
      assert %Figure{axes: %{element: elements, tick: %{y: y_ticks}}} =
               figure
               |> Lead.set_regions_areal()
               |> Cast.cast_yticks_by_region()
               |> Cast.cast_hgrids_by_region()

      assert Enum.filter(elements, fn x -> x.type == "figure.h_grid" end) |> length() ==
               length(y_ticks)
    end
  end

  describe "cast_vgrids_by_region/1" do
    test "add elements for vertical grids", %{figure: figure} do
      assert %Figure{axes: %{element: elements, tick: %{x: x_ticks}}} =
               figure
               |> Lead.set_regions_areal()
               |> Cast.cast_xticks_by_region()
               |> Cast.cast_vgrids_by_region()

      assert Enum.filter(elements, fn x -> x.type == "figure.v_grid" end) |> length() ==
               length(x_ticks)
    end
  end
end
