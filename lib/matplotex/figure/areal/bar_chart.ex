defmodule Matplotex.Figure.Areal.BarChart do
  alias Matplotex.Element.Rect
  alias Matplotex.Figure.RcParams

  alias Matplotex.Figure.Coords
  alias Matplotex.Figure
  alias Nx

  @tensor_data_type_bits 64

  @upadding 0.05

  alias Matplotex.Figure.Areal
  use Areal
  @impl Areal
  def create(x, y) do
    x = determine_numeric_value(x)
    y = determine_numeric_value(y)
    %Figure{axes: struct(__MODULE__, %{data: {x, y}})}
  end

  @impl Areal
  def materialize(figure) do
    __MODULE__.materialized(figure)
    |> materialize_bars()
  end

  defp materialize_bars(
         %Figure{
           axes:
             %{
               data: {x, y},
               limit: %{x: xlim, y: ylim},
               size: {width, height},
               coords: %Coords{bottom_left: {blx, bly}},
               element: elements
             } = axes,
           rc_params: %RcParams{chart_padding: padding}
         } = figure
       ) do
    px = width * padding
    py = height * padding
    width = width - px
    height = height - py

    unit_space = width / length(x)
    bar_width = unit_space - unit_space * @upadding

    bar_elements =
      x
      |> Enum.zip(y)
      |> Enum.map(fn {x, y} ->
        transformation(x, y, xlim, ylim, width, height, {blx + px, bly})
      end)
      |> capture(bar_width, bly, [])

    elements_with_bar = elements ++ bar_elements

    %Figure{figure | axes: %{axes | element: elements_with_bar}}
  end

  defp capture([{x, height} | to_capture], bar_width, bly, captured) do
    capture(
      to_capture,
      bar_width,
      bly,
      captured ++ [%Rect{type: "figure.bar", x: x, y: bly, width: bar_width, height: height}]
    )
  end

  defp capture(_, _, _, captured), do: captured

  def transformation({_label, value}, y, xminmax, yminmax, width, height, transition) do
    transformation(value, y, xminmax, yminmax, width, height, transition)
  end

  def transformation(x, {_label, value}, y, xminmax, yminmax, width, transition) do
    transformation(x, value, y, xminmax, yminmax, width, transition)
  end

  def transformation(
        x,
        y,
        {xmin, xmax},
        {ymin, ymax},
        svg_width,
        svg_height,
        {transition_x, transition_y}
      ) do
    sx = svg_width / (xmax - xmin)
    sy = svg_height / (ymax - ymin)

    tx = transition_x - xmin * sx
    ty = transition_y - ymin * sy

    # TODO: work for the datasets which has values in a range way far from zero in both directi
    point_matrix = Nx.tensor([x, y, 1], type: {:f, @tensor_data_type_bits})

    Nx.tensor(
      [
        [sx, 0, tx],
        [0, sy, ty],
        [0, 0, 1]
      ],
      type: {:f, @tensor_data_type_bits}
    )
    |> Nx.dot(point_matrix)
    |> Nx.to_flat_list()
    |> then(fn [x_trans, y_trans, _] -> {x_trans, y_trans - transition_y} end)
  end
end
