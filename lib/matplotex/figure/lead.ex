defmodule Matplotex.Figure.Lead do
  alias Matplotex.Utils.Algebra
  alias Matplotex.Figure.Areal.XyRegion.Coords, as: XyCoords
  alias Matplotex.Figure.Font
  alias Matplotex.Figure.Areal.Region
  alias Matplotex.Figure.TwoD
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure.RcParams
  alias Matplotex.Figure
  @pt_to_inch 1 / 150
  @padding 10 / 96
  @zero_to_move 0

  @spec set_regions_areal(Matplotex.Figure.t()) :: Matplotex.Figure.t()

  def set_regions_areal(%Figure{figsize: {width, height}, axes: %module{}} = figure)
      when width > 0 and height > 0 do
    figure
    |> set_frame_size()
    |> ensure_ticks_are_valid()
    |> set_region_xy()
    |> module.set_region_title()
    |> module.set_region_legend()
    |> module.set_region_content()
  end

  def set_regions_areal(figure), do: figure

  def set_regions_radial(%Figure{figsize: {width, height}, axes: %module{}} = figure)
      when width > 0 and height > 0 do
    figure
    |> set_frame_size()
    |> module.set_region_title()
    |> module.set_region_legend()
    |> module.set_region_content()
  end

  def set_regions_radial(figure), do: figure

  def set_border(%Figure{margin: margin, axes: axes, figsize: {fig_width, fig_height}} = figure) do
    margin = margin / 2
    lx = fig_width * margin
    by = fig_height * margin
    rx = fig_width - fig_width * margin
    ty = fig_height - fig_height * margin
    %Figure{figure | axes: %{axes | border: {lx, by, rx, ty}}}
  end

  defp set_frame_size(%Figure{margin: margin, figsize: {fwidth, fheight}, axes: axes} = figure) do
    frame_size = {fwidth - fwidth * 2 * margin, fheight - fheight * 2 * margin}
    lx = fwidth * margin
    ty = -fheight * margin
    rx = fwidth - fwidth * margin
    by = fheight * margin - fheight
    %Figure{figure | axes: %{axes | size: frame_size, border: {lx, by, rx, ty}}}
  end

  defp ensure_ticks_are_valid(
         %Figure{
           figsize: {width, height},
           axes:
             %{
               data: {x_data, y_data},
               tick: %TwoD{x: x_ticks, y: y_ticks} = ticks,
               limit: %TwoD{x: x_lim, y: y_lim} = limit
             } = axes
         } = figure
       ) do
    {x_ticks, x_lim} = maybe_generate_ticks(x_ticks, x_lim, x_data, width)
    {y_ticks, y_lim} = maybe_generate_ticks(y_ticks, y_lim, y_data, height)

    %Figure{
      figure
      | axes: %{
          axes
          | tick: %TwoD{ticks | x: x_ticks, y: y_ticks},
            limit: %TwoD{limit | x: x_lim, y: y_lim}
        }
    }
  end

  defp maybe_generate_ticks(ticks, limit, data, number_of_ticks) do
    if is_nil(ticks) || length(ticks) < 3 do
      generate_ticks(limit, data, ceil(number_of_ticks))
    else
      {ticks, limit}
    end
  end

  defp generate_ticks(nil, data, number_of_ticks) do
    {min, upper_limit} = Enum.min_max(data)

    lower_limit =
      if min < 0 do
        min
      else
        0
      end

    generate_ticks({lower_limit, upper_limit}, data, number_of_ticks)
  end

  defp generate_ticks({lower_limit, upper_limit} = lim, _data, number_of_ticks) do
    {lower_limit |> Nx.linspace(upper_limit, n: number_of_ticks) |> Nx.to_list(), lim}
  end

  defp set_region_xy(
         %Figure{
           axes:
             %{
               region_x: region_x,
               region_y: region_y,
               label: %TwoD{y: y_label, x: x_label},
               tick: %TwoD{y: y_ticks, x: x_ticks},
               size: {f_width, f_height},
               border: {lx, by, _rx, _ty}
             } = axes,
           rc_params: %RcParams{
             x_label_font: x_label_font,
             x_tick_font: x_tick_font,
             y_label_font: y_label_font,
             y_tick_font: y_tick_font,
             tick_line_length: tick_line_length
           }
         } = figure
       ) do
    space_for_ylabel = height_required_for_text(y_label_font, y_label)
    y_tick = Enum.max_by(y_ticks, &tick_length(&1))
    space_for_yticks = length_required_for_text(y_tick_font, y_tick)

    space_required_for_region_y =
      [space_for_ylabel, space_for_yticks, tick_line_length] |> Enum.sum()

    space_for_x_label = height_required_for_text(x_label_font, x_label)
    x_tick = Enum.max_by(x_ticks, &tick_length/1)
    space_for_x_tick = height_required_for_text(x_tick_font, x_tick)

    space_required_for_region_x =
      [space_for_x_label, space_for_x_tick, tick_line_length] |> Enum.sum()

    {x_region_x, y_region_x} =
      Algebra.transform_given_point(space_required_for_region_y, @zero_to_move, lx, by)

    {x_region_y, y_region_y} =
      Algebra.transform_given_point(@zero_to_move, space_required_for_region_x, lx, by)

    x_label_coords =
      Algebra.transform_given_point(@zero_to_move, @zero_to_move, x_region_x, y_region_x)

    x_tick_coords =
      Algebra.transform_given_point(@zero_to_move, space_for_x_label, x_region_x, y_region_x)

    y_label_coords =
      Algebra.transform_given_point(@zero_to_move, @zero_to_move, x_region_y, y_region_y)

    y_tick_coords =
      Algebra.transform_given_point(space_for_ylabel, @zero_to_move, x_region_y, y_region_y)

    %Figure{
      figure
      | axes: %{
          axes
          | region_x: %Region{
              region_x
              | x: x_region_x,
                y: y_region_x,
                height: space_required_for_region_x,
                width: f_width - space_required_for_region_y,
                coords: %XyCoords{label: x_label_coords, ticks: x_tick_coords}
            },
            region_y: %Region{
              region_y
              | x: x_region_y,
                y: y_region_y,
                width: space_required_for_region_y,
                height: f_height - space_required_for_region_x,
                coords: %XyCoords{label: y_label_coords, ticks: y_tick_coords}
            }
        }
    }
  end

  def focus_to_origin(%Figure{rc_params: %RcParams{padding: padding}, axes: %{region_content: %Region{x: x_region_content, y: y_region_content, width: width_region_content, height: height_region_content}}=axes}=figure) do
    width_padding_value = width_region_content * padding
    height_padding_value = height_region_content * padding
    radius = plotable_radius(width_region_content, height_region_content, padding)
    {center_x, center_y} = x_region_content|>Algebra.transform_given_point(y_region_content, width_padding_value, height_padding_value)|>Algebra.transform_given_point({radius, radius})

    %Figure{
      figure
      | axes: %{
          axes
          | radius: radius,
            center: %TwoD{x: center_x, y: center_y}
        }
    }
  end
  defp plotable_radius(width, height, padding) when height < width do
    (height - height * padding) / 2
  end
 defp plotable_radius(width, height, padding) when width < height do
  (width - width * padding) / 2
 end
  # def focus_to_origin(
  #       %Figure{
  #         figsize: {width, height},
  #         margin: margin,
  #         rc_params: %RcParams{title_font_size: title_font_size},
  #         axes: %{title: title} = axes
  #       } = figure
  #     ) do
  #   leftx = width * margin
  #   bottomy = height * margin
  #   rightx = width - width * margin
  #   topy = height - height * margin
  #   title_coords = {leftx, topy}
  #   title_offset = label_offset(title, title_font_size)
  #   topy = topy - title_offset
  #   inner_size = {width, height} = {width - 2 * leftx, height - 2 * bottomy - title_offset}

  #   {{centerx, centery}, radius} =
  #     center_and_radius(width, height, {leftx, rightx, bottomy, topy})

  #   coords = %Coords{
  #     title: title_coords,
  #     bottom_left: {leftx, bottomy},
  #     top_left: {leftx, topy},
  #     bottom_right: {rightx, bottomy},
  #     top_right: {rightx, topy}
  #   }

  #   %Figure{
  #     figure
  #     | axes: %{
  #         axes
  #         | radius: radius,
  #           center: %TwoD{x: centerx, y: centery},
  #           coords: coords,
  #           size: inner_size,
  #           legend_pos: {2 * leftx + 2 * radius, topy}
  #       }
  #   }
  # end

  defp center_and_radius(width, height, {leftx, _rightx, bottomy, _topy}) when height < width do
    radius = height / 2

    centerx = leftx + radius
    centery = bottomy + radius
    {{centerx, centery}, radius}
  end

  defp center_and_radius(width, _height, {leftx, _rightx, _bottomy, topy}) do
    radius = width / 2

    centerx = leftx + radius
    centery = topy - radius
    {{centerx, centery}, radius}
  end

  defp label_offset(nil, _font_size), do: 0
  defp label_offset("", _font_size), do: 0

  defp label_offset(ticks, font_size) when is_list(ticks) do
    font_size * @pt_to_inch + @padding
  end

  defp label_offset(_label, font_size) do
    font_size * @pt_to_inch + @padding
  end

  defp tick_length(tick) when is_integer(tick) do
    tick |> Integer.to_string() |> String.length()
  end

  defp tick_length(tick) when is_binary(tick) do
    String.length(tick)
  end

  defp tick_length(tick) when is_float(tick) do
    tick |> Float.round(2) |> Float.to_string() |> String.length()
  end

  defp tick_length({label, _v}) when is_binary(label) do
    String.length(label)
  end

  @doc """
  Calculates the height required for a given text with given font details
  """
  def height_required_for_text(
        %Font{
          font_size: font_size,
          pt_to_inch_ratio: pt_to_inch_ratio,
          flate: flate,
          rotation: 0
        },
        _text
      ) do
    to_number(font_size) * pt_to_inch_ratio + flate
  end

  def height_required_for_text(
         %Font{
           font_size: font_size,
           pt_to_inch_ratio: pt_to_inch_ratio,
           rotation: rotation,
           flate: flate
         },
         text
       ) do
    text_height = to_number(font_size) * pt_to_inch_ratio
    text_length = tick_length(text) * pt_to_inch_ratio
    rotation = deg_to_rad(rotation)
    height_for_rotation = :math.sin(rotation) * text_length
    text_height + height_for_rotation + flate
  end

  @doc """
  Length required for a text string with given font details
  """

  def length_required_for_text(
        %Font{
          font_size: font_size,
          pt_to_inch_ratio: pt_to_inch_ratio,
          flate: flate,
          rotation: 0
        },
        text
      ),
      do: tick_length(text) * to_number(font_size) * (pt_to_inch_ratio / 2) + flate

  def length_required_for_text(
        %Font{
          font_size: font_size,
          pt_to_inch_ratio: pt_to_inch_ratio,
          flate: flate,
          rotation: rotation
        },
        text
      ) do
    text_length = tick_length(text) * to_number(font_size) * (pt_to_inch_ratio / 2)
    rotation = deg_to_rad(rotation)
    leng_for_rotation = :math.cos(rotation) * text_length
    leng_for_rotation + flate
  end

  defp deg_to_rad(deg), do: deg * :math.pi() / 180
  defp to_number(font_size) when is_number(font_size), do: font_size

  defp to_number(font_size) when is_binary(font_size) do
    font_size = String.trim(font_size, "pt")

    if String.contains?(font_size, ".") do
      String.to_float(font_size)
    else
      String.to_integer(font_size)
    end
  end
end
