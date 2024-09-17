defmodule Matplotex.Utils.Algebra do
  alias Nx

  @tensor_data_type_bits 64

  @spec transformation(
          number(),
          number(),
          {number(), number()},
          {number(), number()},
          number(),
          number()
        ) ::
          {number(), number()}
  def transformation(x, y, {xmin, xmax}, {ymin, ymax}, svg_width, svg_height) do
    sx = svg_width / (xmax - xmin)
    sy = svg_height / (ymax - ymin)

    # TODO: work for the datasets which has values in a range way far from zero in both direction
    tx = -xmin * sx
    ty = svg_height - ymin * sy
    point_matrix = Nx.tensor([x, y, 1], type: {:f, @tensor_data_type_bits})

    Nx.tensor(
      [
        [sx, 0, tx],
        [0, -sy, ty],
        [0, 0, 1]
      ],
      type: {:f, @tensor_data_type_bits}
    )
    |> Nx.dot(point_matrix)
    |> Nx.to_flat_list()
    |> then(fn [x_trans, y_trans, _] -> {x_trans, y_trans} end)
  end

  def rotation({x, y}, theeta) do
    Nx.tensor(
      [
        [:math.cos(theeta), -:math.sin(theeta)],
        [:math.sin(theeta), :math.sin(theeta)]
      ],
      type: {:f, @tensor_data_type_bits}
    )
    |> Nx.dot([x, y])
    |> Nx.to_flat_list()
    |> List.to_tuple()
  end

def svgfy(y, height), do: height - y
end
