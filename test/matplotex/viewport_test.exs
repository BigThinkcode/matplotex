defmodule Matplotex.ViewportTest do
  use ExUnit.Case, async: true
  alias Matplotex.Viewport

  describe "to_matrix/1" do
    test "identity viewport gives identity-like matrix (no pan, zoom=1)" do
      vp = %Viewport{}
      m  = Viewport.to_matrix(vp)
      assert Nx.to_number(m[0][0]) == 1.0
      assert Nx.to_number(m[1][1]) == 1.0
      assert Nx.to_number(m[0][2]) == 0.0
      assert Nx.to_number(m[1][2]) == 0.0
    end

    test "zoom > 1 increases scale factors" do
      vp = %Viewport{zoom_x: 2.0, zoom_y: 2.0}
      m  = Viewport.to_matrix(vp)
      assert Nx.to_number(m[0][0]) == 2.0
      assert Nx.to_number(m[1][1]) == 2.0
    end
  end

  describe "zoom/3" do
    test "increases zoom factors" do
      vp = %Viewport{}
      z  = Viewport.zoom(vp, 1, {0.5, 0.5})
      assert z.zoom_x > 1.0
      assert z.zoom_y > 1.0
    end

    test "negative delta decreases zoom" do
      vp = %Viewport{zoom_x: 2.0, zoom_y: 2.0}
      z  = Viewport.zoom(vp, -1, {0.5, 0.5})
      assert z.zoom_x < 2.0
    end
  end

  describe "pan/3" do
    test "shifts pan offsets" do
      vp  = %Viewport{}
      vp2 = Viewport.pan(vp, 0.1, 0.2)
      assert vp2.pan_x != vp.pan_x
      assert vp2.pan_y != vp.pan_y
    end
  end

  describe "reset/1" do
    test "returns default viewport" do
      vp      = %Viewport{zoom_x: 3.0, pan_x: 0.5}
      default = Viewport.reset(vp)
      assert default.zoom_x == 1.0
      assert default.pan_x  == 0.0
    end
  end
end
