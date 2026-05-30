defmodule Matplotex.DatasetTest do
  use ExUnit.Case, async: true
  alias Matplotex.Dataset

  describe "from_pairs/2" do
    test "converts list of tuples to Nx tensors" do
      ds = Dataset.from_pairs([{1, 2}, {3, 4}, {5, 6}])
      assert %Dataset{} = ds
      assert Nx.to_list(ds.x) == [1.0, 3.0, 5.0]
      assert Nx.to_list(ds.y) == [2.0, 4.0, 6.0]
    end

    test "accepts name and color options" do
      ds = Dataset.from_pairs([{0, 1}], name: "Series A", color: "#ff0000")
      assert ds.name  == "Series A"
      assert ds.color == "#ff0000"
    end
  end

  describe "from_columns/1" do
    test "builds from x and y lists" do
      ds = Dataset.from_columns(x: [1, 2, 3], y: [4, 5, 6])
      assert Nx.to_list(ds.x) == [1.0, 2.0, 3.0]
      assert Nx.to_list(ds.y) == [4.0, 5.0, 6.0]
    end

    test "z is nil when not provided" do
      ds = Dataset.from_columns(x: [1, 2], y: [3, 4])
      assert is_nil(ds.z)
    end

    test "accepts z column" do
      ds = Dataset.from_columns(x: [1, 2], y: [3, 4], z: [5, 6])
      assert Nx.to_list(ds.z) == [5.0, 6.0]
    end
  end

  describe "size/1" do
    test "returns number of data points" do
      ds = Dataset.from_pairs(Enum.zip(1..7, 1..7))
      assert Dataset.size(ds) == 7
    end
  end

  describe "to_homogeneous/1" do
    test "returns {3, n} tensor with ones in last row" do
      ds = Dataset.from_pairs([{1, 2}, {3, 4}])
      h  = Dataset.to_homogeneous(ds)
      assert Nx.shape(h) == {3, 2}
      assert Nx.to_list(h[2]) == [1.0, 1.0]
    end
  end
end
