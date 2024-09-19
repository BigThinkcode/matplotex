defmodule Matplotex.Element.GridLine do
  alias Matplotex.Element.Line
  alias Matplotex.Utils.Algebra

  @stroke_grid "#ddd"
  @v_grid_type "grid.vertical"
  @h_grid_type "grid.horizontal"
  @point_zero 0
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

    {h_grid_coords, h_grid_lines} =
      generate_grids(
        {x_scale, content_x, content_y, content_width, content_height, {x_min, x_max},
         {y_min, y_max}},
        size,
        show_h_grid,
        :h_grid
      )

    {v_grid_coords, v_grid_lines} =
      generate_grids(
        {y_scale, content_x, content_y, content_width, content_height, {x_min, x_max},
         {y_min, y_max}},
        size,
        show_v_grid,
        :v_grid
      )

    %{
      chartset
      | element: %{element | grid: h_grid_lines ++ v_grid_lines},
        grid_coordinates: %{h: h_grid_coords, v: v_grid_coords}
    }
  end

  defp generate_grids(
         {y_scale, content_x,_content_y, content_width, content_height, x_min_max,
          {_y_min, y_max} = y_min_max},
         %{width: width},
         true,
         :h_grid
       ) do
    grids = div(y_max, y_scale)

    1..grids
    |> Enum.map(fn grid ->
      y_point = grid * y_scale

      {_x_trans, y_trans} =
        Algebra.transformation(
          @point_zero,
          y_point,
          x_min_max,
          y_min_max,
          content_width,
          content_height
        )



      line = %Line{
        type: @h_grid_type,
        x1: content_x,
        y1: y_trans,
        x2: width,
        y2: y_trans,
        stroke: @stroke_grid,
        stroke_width: @stroke_width_grid
      }

      {{content_x, y_trans}, line}
    end)
    |> Enum.unzip()
  end

  defp generate_grids(
         {y_scale, content_x, content_y, content_width, content_height,
          {_x_min, x_max} = x_min_max, y_min_max},
         %{height: height},
         true,
         :v_grid
       ) do
    grids = div(x_max, y_scale)

    1..grids
    |> Enum.map(fn grid ->
      x_point = grid * y_scale

      {x_trans, _y_trans} =
        Algebra.transformation(
          x_point,
          @point_zero,
          x_min_max,
          y_min_max,
          content_width,
          content_height
        )

      line = %Line{
        type: @v_grid_type,
        x1: x_trans + content_x,
        y1: content_y,
        x2: x_trans + content_x,
        y2: Algebra.svgfy(height, height),
        stroke: @stroke_grid,
        stroke_width: @stroke_width_grid
      }

      {{x_trans, content_y}, line}
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
