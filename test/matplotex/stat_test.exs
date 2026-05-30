defmodule Matplotex.StatTest do
  use ExUnit.Case, async: true
  alias Matplotex.Stat

  describe "histogram/2" do
    test "returns edges and counts" do
      x = Nx.tensor([1.0, 2.0, 3.0, 4.0, 5.0], type: :f64)
      {edges, counts} = Stat.histogram(x, 5)
      assert Nx.size(edges)  == 6
      assert Nx.size(counts) == 5
    end

    test "total count equals n" do
      x = Nx.tensor(Enum.map(1..50, &(&1 * 1.0)), type: :f64)
      {_, counts} = Stat.histogram(x, 10)
      assert Nx.sum(counts) |> Nx.to_number() == 50.0
    end
  end

  describe "level_of_detail/3" do
    test "returns original data when n <= pixel_width * 2" do
      x = Nx.tensor([1.0, 2.0, 3.0], type: :f64)
      y = Nx.tensor([4.0, 5.0, 6.0], type: :f64)
      {rx, ry} = Stat.level_of_detail(x, y, 10)
      assert Nx.to_list(rx) == Nx.to_list(x)
    end

    test "downsamples when n > pixel_width * 2" do
      x = Nx.tensor(Enum.map(1..100, &(&1 * 1.0)), type: :f64)
      y = Nx.tensor(Enum.map(1..100, &(&1 * 2.0)), type: :f64)
      {rx, ry} = Stat.level_of_detail(x, y, 20)
      assert Nx.size(rx) == 20
      assert Nx.size(ry) == 20
    end
  end

  describe "five_number_summary/1" do
    test "returns correct quartiles for known data" do
      x = Nx.tensor([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0], type: :f64)
      {mn, q1, med, q3, mx} = Stat.five_number_summary(x)
      assert mn  == 1.0
      assert mx  == 10.0
      assert med == 5.5
      assert q1  < med
      assert q3  > med
    end
  end

  describe "kde/2" do
    test "returns xs and densities of requested length" do
      x = Nx.tensor(Enum.map(1..30, fn _ -> :rand.normal() end), type: :f64)
      {xs, dens} = Stat.kde(x, 50)
      assert Nx.size(xs)   == 50
      assert Nx.size(dens) == 50
    end

    test "densities are non-negative" do
      x = Nx.tensor([0.0, 1.0, 2.0, 3.0, 4.0], type: :f64)
      {_, dens} = Stat.kde(x, 20)
      assert Nx.reduce_min(dens) |> Nx.to_number() >= 0.0
    end
  end

  describe "colorscale/2" do
    test "returns a hex string" do
      assert Stat.colorscale(0.5, :viridis) =~ ~r/^#[0-9a-f]{6}$/i
    end

    test "t=0 and t=1 produce different colors" do
      assert Stat.colorscale(0.0, :blues) != Stat.colorscale(1.0, :blues)
    end
  end
end
