defmodule Matplotex.ScaleTest do
  use ExUnit.Case, async: true
  alias Matplotex.Scale

  describe "translate/2" do
    test "returns 3×3 identity shifted by tx, ty" do
      m = Scale.translate(10.0, 20.0)
      assert Nx.to_list(m) == [[1.0, 0.0, 10.0], [0.0, 1.0, 20.0], [0.0, 0.0, 1.0]]
    end
  end

  describe "scale/2" do
    test "returns 3×3 scale matrix" do
      m = Scale.scale(2.0, 3.0)
      assert Nx.to_list(m) == [[2.0, 0.0, 0.0], [0.0, 3.0, 0.0], [0.0, 0.0, 1.0]]
    end

    test "negative sy flips y-axis" do
      m = Scale.scale(1.0, -1.0)
      assert Nx.to_list(m) |> Enum.at(1) |> Enum.at(1) == -1.0
    end
  end

  describe "compose/2" do
    test "identity composed with any matrix returns that matrix" do
      m = Scale.translate(5.0, 3.0)
      assert_tensors_close(Scale.compose(Scale.identity(), m), m)
    end

    test "two translations compose correctly" do
      m1 = Scale.translate(1.0, 2.0)
      m2 = Scale.translate(3.0, 4.0)
      result = Scale.compose(m1, m2)
      # translate(4, 6)
      assert Nx.to_number(result[0][2]) |> round() == 4
      assert Nx.to_number(result[1][2]) |> round() == 6
    end
  end

  describe "linear/5" do
    test "maps domain to range on x-axis" do
      m = Scale.linear(0.0, 100.0, 0.0, 600.0, :x)
      # point at x=50 should map to pixel 300
      p = Nx.dot(m, Nx.tensor([[50.0], [0.0], [1.0]], type: :f64))
      assert_in_delta Nx.to_number(p[0][0]), 300.0, 0.01
    end

    test "maps domain to range on y-axis" do
      m = Scale.linear(0.0, 100.0, 0.0, 400.0, :y)
      p = Nx.dot(m, Nx.tensor([[0.0], [50.0], [1.0]], type: :f64))
      assert_in_delta Nx.to_number(p[1][0]), 200.0, 0.01
    end
  end

  describe "data_to_pixel/3" do
    test "maps domain corners to plot corners" do
      x_scale = Scale.axis_scale(0.0, 10.0)
      y_scale = Scale.axis_scale(0.0, 10.0)
      plot    = Nx.tensor([100.0, 50.0, 500.0, 300.0], type: :f64)

      transform = Scale.data_to_pixel(x_scale, y_scale, plot)

      # (0,0) → (plot_x, plot_y + plot_h) = (100, 350) — bottom-left
      p00 = Nx.dot(transform, Nx.tensor([[0.0], [0.0], [1.0]], type: :f64))
      assert_in_delta Nx.to_number(p00[0][0]), 100.0, 0.5
      assert_in_delta Nx.to_number(p00[1][0]), 350.0, 0.5

      # (10,10) → (plot_x + plot_w, plot_y) = (600, 50) — top-right
      p11 = Nx.dot(transform, Nx.tensor([[10.0], [10.0], [1.0]], type: :f64))
      assert_in_delta Nx.to_number(p11[0][0]), 600.0, 0.5
      assert_in_delta Nx.to_number(p11[1][0]), 50.0, 0.5
    end
  end

  describe "apply/2" do
    test "returns {2, n} pixel matrix" do
      x_scale = Scale.axis_scale(0.0, 1.0)
      y_scale = Scale.axis_scale(0.0, 1.0)
      plot = Nx.tensor([0.0, 0.0, 100.0, 100.0], type: :f64)
      transform = Scale.data_to_pixel(x_scale, y_scale, plot)

      points = Nx.tensor([[0.0, 0.5, 1.0], [0.0, 0.5, 1.0], [1.0, 1.0, 1.0]], type: :f64)
      result = Scale.apply(transform, points)

      assert Nx.shape(result) == {2, 3}
    end
  end

  describe "infer_domain/2" do
    test "uses data min/max" do
      t = Nx.tensor([2.0, 5.0, 8.0], type: :f64)
      d = Scale.infer_domain(t, origin_at_zero: false)
      assert d.domain_min == 2.0
      assert d.domain_max == 8.0
    end

    test "forces domain_min to 0 for positive data when origin_at_zero" do
      t = Nx.tensor([3.0, 7.0, 5.0], type: :f64)
      d = Scale.infer_domain(t, origin_at_zero: true)
      assert d.domain_min == 0.0
    end

    test "does not force 0 for negative data" do
      t = Nx.tensor([-5.0, 2.0, 8.0], type: :f64)
      d = Scale.infer_domain(t, origin_at_zero: true)
      assert d.domain_min == -5.0
    end
  end

  defp assert_tensors_close(a, b) do
    diff = Nx.abs(Nx.subtract(a, b)) |> Nx.reduce_max() |> Nx.to_number()
    assert diff < 1.0e-6, "Tensors differ by #{diff}"
  end
end
