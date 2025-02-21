defmodule Matplotex.Figure.Areal.ScatterTest do
  alias Matplotex.Figure.Areal
  alias Matplotex.Figure.Dataset
  alias Matplotex.Figure.Areal.Scatter
  alias Matplotex.Figure
  use Matplotex.PlotCase

  setup do
    {:ok, %{figure: Matplotex.FrameHelpers.scatter()}}
  end

  describe "materialyze/1" do
    test "adds elements for dat", %{figure: figure} do
      assert %Figure{axes: %{data: {x, _y}, element: elements}} = Scatter.materialize(figure)
      assert Enum.count(elements, fn elem -> elem.type == "plot.marker" end) == length(x)
    end
  end

  describe "generate_ticks/2" do
    test "5 ticks will generate by default" do
      minmax = {1, 10}
      # inch

      {ticks, _lim} = Scatter.generate_ticks(minmax)
      # 5 ticks added with minimum value
      assert length(ticks) == 6
    end
  end
  describe "do_transform" do
    test "zips transformed values with sizes if the dataset contains sizes in eaqual size" do
      x = [1,2,3,4,5]
      y = [10, 20, 30, 40, 50]
      sizes = [1, 2, 3, 4, 5]
      width = 2
      height = 2
      assert %Figure{axes: %{dataset: [dataset]}} = x|>Matplotex.scatter(y,figsize: {width, height}, sizes: sizes)
      assert %Dataset{transformed: transformed} = Areal.do_transform(dataset, Enum.min_max(x), Enum.min_max(y),width, height, {0,0})
      assert Enum.all?(transformed, &match?({{_,_},_}, &1))

    end
    test "zips transformed values with colors if the dataset contanis colors" do
      x = [1,2,3,4,5]
      y = [10, 20, 30, 40, 50]
      colors = [1, 2, 3, 4, 5]
      width = 2
      height = 2
      assert %Figure{axes: %{dataset: [dataset]}} = x|>Matplotex.scatter(y,figsize: {width, height}, colors: colors)
      assert %Dataset{transformed: transformed} = Areal.do_transform(dataset, Enum.min_max(x), Enum.min_max(y),width, height, {0,0})

      assert Enum.all?(transformed, &match?({{_,_},_}, &1))

    end

    test "zips both size and colors if the dataset contains size and color" do
      x = [1,2,3,4,5]
      y = [10, 20, 30, 40, 50]
      sizes = [1, 2, 3, 4, 5]
      colors = [1, 2, 3, 4, 5]
      width = 2
      height = 2
      assert %Figure{axes: %{dataset: [dataset]}} = x|>Matplotex.scatter(y,figsize: {width, height}, sizes: sizes, colors: colors)
      assert %Dataset{transformed: transformed} = Areal.do_transform(dataset, Enum.min_max(x), Enum.min_max(y),width, height, {0,0})

      assert Enum.all?(transformed, &match?({{{_,_},_},_}, &1))

    end
  end
end
