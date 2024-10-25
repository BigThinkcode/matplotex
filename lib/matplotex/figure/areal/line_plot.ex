defmodule Matplotex.LinePlot do
  alias Matplotex.Figure.RcParams
  alias Matplotex.Element.Line
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure
  alias Nx

  @tensor_data_type_bits 64

  use Matplotex.Figure.Areal

  def create(x, y) do
    x = determine_numeric_value(x)
    y = determine_numeric_value(y)
    %Figure{axes: struct(__MODULE__, %{data: {x, y}})}
  end
  def materialize(figure) do
    figure
    |>__MODULE__.materialized()
    |> materialize_lines()
  end

  defp materialize_lines(%Figure{axes: %{data: {x, y},limit: %{x: xlim, y: ylim},size: {width, height},coords: %Coords{bottom_left: {blx, bly}}, element: elements} = axes, rc_params: %RcParams{chart_padding: padding}} = figure) do
  px = width * padding
  py = height * padding
  width = width - px
  height = height - py


  line_elements =
    x
    |>Enum.zip(y)
    |>Enum.map(fn {x, y} ->
      transformation(x, y, xlim, ylim, width, height, {blx + px, bly + py})
    end)
    |> capture([])
    elements = elements ++ line_elements
    %Figure{figure | axes: %{axes | element: elements}}
  end

  defp capture([{x1, y1} | [{x2, y2} | _] = to_capture ], captured ) do
    capture(to_capture,captured ++ [%Line{x1: x1, y1: y1, x2: x2, y2: y2}])
  end
  defp capture(_, captured), do: captured
  def transformation({ _label,value}, y, xminmax, yminmax, width, height, transition) do
    transformation(value, y, xminmax, yminmax, width, height, transition)
  end
  def transformation(x, { _label,value}, y, xminmax, yminmax, width, transition) do
    transformation(x, value, y, xminmax, yminmax, width, transition)
  end
  def transformation(x, y, {xmin, xmax}, {ymin, ymax}, svg_width, svg_height, {tx, ty}) do
    sx = svg_width / (xmax - xmin)
    sy = svg_height / (ymax - ymin)

    tx = tx - xmin * sx
    ty = ty - ymin * sy

    # TODO: work for the datasets which has values in a range way far from zero in both directi
    point_matrix = Nx.tensor([x, y, 1], type: {:f, @tensor_data_type_bits})

    Nx.tensor(
      [
        [sx, 0, tx ],
        [0, sy, ty],
        [0, 0, 1]
      ],
      type: {:f, @tensor_data_type_bits}
    )
    |> Nx.dot(point_matrix)
    |> Nx.to_flat_list()
    |> then(fn [x_trans, y_trans, _] -> {x_trans, y_trans} end)
  end

  defp determine_numeric_value(data) when is_list(data) do
    if  number_based?(data) do
      data
    else
      data_with_label(data)
    end
  end
  defp data_with_label(data) do
    Enum.with_index(data)
  end

end
