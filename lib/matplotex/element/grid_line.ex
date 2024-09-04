defmodule Matplotex.Element.GridLine do
  alias Matplotex.Element.Line
  alias Matplotex.Utils.Algebra

  def generate_grid_lines(%{content: %{width: width, height: height},scale: %{x: x_scale, y: y_scale}},{x_min, x_max}, {y_min, y_max}) do
    x_max  = calculate_max(x_max, x_scale)
    y_max = calculate_max(y_max, y_scale)

    x_grids = generate_grids(x_scale, {x_min, x_max},{y_min, y_max}, :x)
  end
  defp generate_grids(x_scale, {_x_min, x_max} =x_min_max, y_min_max, :x) do
    grids = div(x_max, x_scale)
    1..grids
    |>Enum.map(fn grid ->
      x_point = grid * x_scale
      Algebra.transformation(x_point, )
    end)

  end

  defp calculate_max(max, scale) do
    if rem(max, scale) == 0 do
      max
    else
      max - rem(max, scale) + scale
    end
  end
end
