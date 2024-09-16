defmodule Matplotex.Element.GridLine do
  alias Matplotex.Element.Line
  alias Matplotex.Utils.Algebra

  @stroke_grid "#ddd"
  @v_grid_type "grid.vertical"
  @h_grid_type "grid.horizontal"

  @stroke_width_grid 1

  def generate_grid_lines(
        %{
          size: size,
          element: element,
          content: %{width: content_width, height: content_height, x: content_x, y: content_y},
          scale: %{x: x_scale, y: y_scale},
          show_h_grid: show_h_grid,
          show_v_grid: show_v_grid
        } = chartset,
        {x_min, x_max},
        {y_min, y_max}
      ) do
    x_max = calculate_max(x_max, x_scale)
    y_max = calculate_max(y_max, y_scale)

    {x_grid_coords, x_grid_lines} =
      generate_grids(
        {x_scale, content_x, content_y, content_width, content_height, {x_min, x_max},
         {y_min, y_max}},
        size,
        show_h_grid,
        :h_grid
      )

    {y_grid_coords, y_grid_lines} =
      generate_grids(
        {y_scale, content_x, content_y, content_width, content_height, {x_min, x_max},
         {y_min, y_max}},
        size,
        show_v_grid,
        :v_grid
      )

    %{
      chartset
      | element: %{element | grid: %{x: x_grid_lines, y: y_grid_lines}},
        grid_coordinates: %{x: x_grid_coords, y: y_grid_coords}
    }
  end

  defp generate_grids(
         {y_scale, content_x, content_y, content_width, content_height, x_min_max,
          {_y_min, y_max} = y_min_max},
         %{width: width},
         true,
         :h_grid
       ) do
    grids = div(y_max, y_scale)

    1..grids
    |> Enum.map(fn grid ->
      x_point = content_x
      y_point = content_y + grid * y_scale

      coords =
        {x_trans, y_trans} =
        Algebra.transformation(
          x_point,
          y_point,
          x_min_max,
          y_min_max,
          content_width,
          content_height
        )
        |> Algebra.transform_to_svg(content_height)

      line = %Line{
        type: @h_grid_type,
        x1: x_trans,
        y1: y_trans,
        x2: width,
        y2: y_trans,
        stroke: @stroke_grid,
        stroke_width: @stroke_width_grid
      }

      {coords, line}
    end)
    |> Enum.unzip()
  end

  defp generate_grids(
         {y_scale, content_x, content_y, content_width, content_height, {_x_min, x_max} = x_min_max, y_min_max},
         %{height: height},
         true,
         :v_grid
       ) do
    grids = div(x_max, y_scale)

    1..grids
    |> Enum.map(fn grid ->
      x_point = content_x + grid * y_scale
      y_point = content_y

      coords =
        {x_trans, y_trans} =
        Algebra.transformation(x_point, y_point, x_min_max, y_min_max, content_width, content_height) |>Algebra.transform_to_svg(content_height)

      line = %Line{
        type: @v_grid_type,
        x1: x_trans,
        y1: y_trans,
        x2: x_trans,
        y2: height,
        stroke: @stroke_grid,
        stroke_width: @stroke_width_grid
      }

      {coords, line}
    end)
    |> Enum.unzip()
  end

  defp generate_grids(_, _, _, _), do: []

  defp calculate_max(max, scale) do
    if rem(max, scale) == 0 do
      max
    else
      max - rem(max, scale) + scale
    end
  end
end
