defmodule Matplotex.Utilities.MathFunc do
@moduledoc false
  alias NX
  @tensor_double_data_type_bits 64
  def euclidean_distance(x1, y1, x2, y2) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end

  def compute_arrow_points(xs, ys, xe, ye, width) do
    # Height  of the arrow twice of its width
    # Also the triangle width is twice of its line width
    tri_width = 2 * width
    tri_height = 3 * tri_width
    path_length = euclidean_distance(xs, ys, xe, ye)
    x_tri_base_mid = xs + tri_height / path_length * (xe - xs)
    y_tri_base_mid = ys + tri_height / path_length * (ye - ys)

    unit_vector = {(xs - xe) / path_length, (ys - ye) / path_length}

    perpendicular_unit_vector1 = {-elem(unit_vector, 1), elem(unit_vector, 0)}
    perpendicular_unit_vector2 = {elem(unit_vector, 1), -elem(unit_vector, 0)}

    {x2, y2} =
      {x_tri_base_mid + tri_width / 2 * elem(perpendicular_unit_vector1, 0),
       y_tri_base_mid + tri_width / 2 * elem(perpendicular_unit_vector1, 1)}

    {x3, y3} =
      {x_tri_base_mid + tri_width / 2 * elem(perpendicular_unit_vector2, 0),
       y_tri_base_mid + tri_width / 2 * elem(perpendicular_unit_vector2, 1)}

    {xs, ys, x2, y2, x3, y3}
  end

  def homogeneous_transformation_matrix(theta_in_rad, ox, oy) do
    Nx.tensor(
      [
        [:math.cos(theta_in_rad), -:math.sin(theta_in_rad), ox],
        [:math.sin(theta_in_rad), :math.cos(theta_in_rad), oy],
        [0, 0, 1]
      ],
      type: {:f, @tensor_double_data_type_bits}
    )
  end

  def scalar_matrix(sx, sy) do
    Nx.tensor(
      [[sx, 0, 0], [0, sy, 0], [0, 0, 1]],
      type: {:f, @tensor_double_data_type_bits}
    )
  end

  def convert_input_single_data_to_svg_frame(x, y, theta_in_rad, ox, oy, sx, sy) do
    homogeneous_transformation_matrix(theta_in_rad, ox, oy)
    |> Nx.dot(scalar_matrix(sx, sy))
    |> Nx.dot(Nx.tensor([[x], [y], [1]], type: {:f, @tensor_double_data_type_bits}))
    |> Nx.to_flat_list()
    |> then(fn [x_trans, y_trans | _] -> {x_trans, y_trans} end)
  end

  def convert_input_multiple_data_to_svg_frame(x_list, y_list, theta_in_rad, ox, oy, sx, sy) do
    Enum.zip(x_list, y_list)
    |> Enum.reduce({[], []}, fn {x, y}, {x_trans_list, y_trans_list} ->
      {x_trans, y_trans} =
        convert_input_single_data_to_svg_frame(x, y, theta_in_rad, ox, oy, sx, sy)

      {[x_trans | x_trans_list], [y_trans | y_trans_list]}
    end)
    |> then(fn {x_trans_list, y_trans_list} ->
      {x_trans_list |> Enum.reverse(), y_trans_list |> Enum.reverse()}
    end)
  end
end
