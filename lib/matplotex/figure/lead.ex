defmodule Matplotex.Figure.Lead do
  alias Matplotex.Figure.Dimension
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure.RcParams
  alias Matplotex.Figure
  @pt_to_inch 1 / 72
  @padding 10 / 96
  @tick_line_offset 5 / 96

  # def set_spines(%Figure{} = figure) do
  #   # {{width, height}, {bottom_left, top_left, bottom_right, top_right}} =
  #   {%Figure{axes: axes}, {width, height}} =
  #     figure
  #     |> peel_margin()
  #     |> peel_label_offsets()
  #     |> peel_title_offset()
  #     |> peel_tick_offsets()
  #     |> calculate_corners()
  #     |> peel_margin()

  #   axes = %{
  #     axes
  #     | size: %{width: width * @dpi, height: height * @dpi}
  #   }

  #   %Figure{figure | axes: axes}
  # end

  # def set_spines(_) do
  #   raise ArgumentError, message: "Invalid figure to proceed"
  # end
  def set_spines(%Figure{} = figure) do
    figure
    |> set_xlabel_coords()
    |> set_ylabel_coords()
    |> set_title_coords()
    |> set_xticks_coords()
    |> set_yticks_coords()
    |> set_border_coords()
  end

  defp set_xlabel_coords(%Figure{axes: %{tick: %{y: nil}, show_y_ticks: true}} = figure) do
    figure
    |> generate_yticks()
    |> set_xlabel_coords()
  end

  defp set_xlabel_coords(
         %Figure{
           rc_params: rc_params,
           margin: margin,
           figsize: {f_width, f_height},
           axes: %{coords: coords, tick: %{y: y_ticks}, dimension: dimension} = axes
         } = figure
       ) do
    y_label_font_size = RcParams.get_rc(rc_params, :get_y_label_font_size)
    y_tick_font_size = RcParams.get_rc(rc_params, :get_y_tick_font_size)
    label_offset = label_offset(y_label_font_size)
    y_tick_offset = ytick_offset(y_ticks, y_tick_font_size)
    y_tick_height = label_offset(y_tick_font_size)

    x_labelx =
      f_width * margin + label_offset + y_tick_offset

    %Figure{
      figure
      | axes: %{
          axes
          | coords: %Coords{coords | x_label: {x_labelx, f_height * margin}},
            dimension: %Dimension{
              dimension
              | y_label: {0, label_offset},
                y_tick: {y_tick_offset, y_tick_height}
            }
        }
    }
  end

  defp set_xlabel_coords(%Figure{} = figure), do: figure

  defp set_ylabel_coords(%Figure{axes: %{tick: %{x: nil}, show_x_ticks: true}} = figure) do
    figure
    |> generate_xticks()
    |> set_ylabel_coords()
  end

  defp set_ylabel_coords(
         %Figure{
           rc_params: rc_params,
           margin: margin,
           figsize: {f_width, f_height},
           axes: %{coords: coords, dimension: dimension, tick: %{x: x_ticks}} = axes
         } = figure
       ) do
    x_label_font_size = RcParams.get_rc(rc_params, :get_x_label_font_size)
    x_tick_font_size = RcParams.get_rc(rc_params, :get_x_tick_font_size)
    xlabel_offset = label_offset(x_label_font_size)
    x_tick_offset = xtick_offset(x_tick_font_size)
    x_tick_width = ytick_offset(x_ticks, x_tick_font_size)

    y_labely =
      f_height * margin + xlabel_offset + x_tick_offset

    %Figure{
      figure
      | axes: %{
          axes
          | coords: %Coords{coords | y_label: {f_width * margin, y_labely}},
            dimension: %Dimension{
              dimension
              | x_label: {0, xlabel_offset},
                x_tick: {x_tick_width, x_tick_offset}
            }
        }
    }
  end

  defp set_ylabel_coords(%Figure{} = figure), do: figure

  defp set_title_coords(
         %Figure{
           margin: margin,
           figsize: {_f_width, f_height},
           axes: %{coords: %Coords{x_label: {xlx, _xly}} = coords} = axes
         } = figure
       ) do
    %Figure{
      figure
      | axes: %{axes | coords: %Coords{coords | title: {xlx, f_height - f_height * margin}}}
    }
  end

  defp set_xticks_coords(
         %Figure{
           rc_params: rc_params,
           axes: %{coords: %Coords{x_label: {xlx, xly}} = coords} = axes
         } = figure
       ) do
    x_label_font_size = RcParams.get_rc(rc_params, :get_x_label_font_size)
    xlable_offset = label_offset(x_label_font_size)

    %Figure{
      figure
      | axes: %{axes | coords: %Coords{coords | x_ticks: {xlx, xly + xlable_offset}}}
    }
  end

  defp set_yticks_coords(
         %Figure{
           rc_params: rc_params,
           axes: %{coords: %Coords{y_label: {ylx, yly}} = coords} = axes
         } = figure
       ) do
    y_label_font_size = RcParams.get_rc(rc_params, :get_y_label_font_size)
    ylabel_offset = label_offset(y_label_font_size)

    %Figure{
      figure
      | axes: %{axes | coords: %Coords{coords | y_ticks: {ylx + ylabel_offset, yly}}}
    }
  end

  defp set_border_coords(
         %Figure{
           margin: margin,
           figsize: {f_width, _},
           rc_params: rc_params,
           axes:
             %{
               coords: %Coords{x_label: {xlx, _}, y_label: {_ylx, yly}, title: {_, ytt}} = coords,
               title: title
             } =
               axes
         } = figure
       ) do
    bottom_left = {xlx, yly}
    title_offset = rc_params |> RcParams.get_rc(:get_title_font_size) |> label_offset()
    topy = ytt - title_offset
    top_left = {xlx, topy}
    rightx = f_width - f_width * margin
    top_right = {rightx, topy}
    bottom_right = {rightx, yly}
    width = rightx - xlx
    height = topy - yly

    %Figure{
      figure
      | axes: %{
          axes
          | coords: %Coords{
              coords
              | bottom_left: bottom_left,
                top_right: top_right,
                bottom_right: bottom_right,
                top_left: top_left
            },
            size: {width, height},
            title: %{title | height: title_offset}
        }
    }
  end

  # TODO: Sort out how the user gets the control on font of the all texts

  # defp calculate_corners(
  #        {%Figure{axes: %{coords: coords} = axes, figsize: {f_width, f_height}, margin: margin} =
  #           figure, {width, height}}
  #      ) do
  #   by = f_height - height
  #   ty = f_height - f_height * margin
  #   lx = f_width - width
  #   rx = f_width - f_width * margin

  #   {%Figure{
  #      figure
  #      | axes: %{
  #          axes
  #          | coords: %{
  #              coords
  #              | bottom_left: {lx * @dpi, by * @dpi},
  #                top_left: {lx * @dpi, ty * @dpi},
  #                bottom_right: {rx * @dpi, by * @dpi},
  #                top_right: {rx * @dpi, ty * @dpi}
  #            }
  #        }
  #    }, {width, height}}
  # end

  # defp peel_margin(
  #        %Figure{figsize: {width, height}, axes: %{coords: coords} = axes, margin: margin} =
  #          figure
  #      ) do
  #   label_coords = {width * margin, height * margin}

  #   {%Figure{
  #      figure
  #      | axes: %{
  #          axes
  #          | coords: %{
  #              coords
  #              | title: {width * margin, height - height * margin},
  #                y_label: label_coords,
  #                x_label: label_coords
  #            }
  #        }
  #    }, {width - width * margin, height - height * margin}}
  # end

  # # defp peel_margin({width, height, corners}, margin, {f_width, f_height}) do
  # #   {{width - f_width * margin, height - f_height * margin}, corners}
  # # end
  # defp peel_margin(
  #        {%Figure{figsize: {f_width, f_height}, margin: margin} = figure, {width, height}}
  #      ) do
  #   {figure, {width - f_width * margin, height - f_height * margin}}
  # end

  defp label_offset(font_size) do
    font_size * @pt_to_inch + @padding
  end

  # defp peel_label_offsets(
  #        {%Figure{
  #           axes: %{coords: %Coords{x_label: {xlx, xly}, y_label: {ylx, yly}} = coords, label: %{}} = axes,
  #           rc_params: rc_params
  #         } = figure, {width, height}}
  #      ) do
  #   x_label_font_size = RcParams.get_rc(rc_params, :get_x_label_font_size)
  #   y_label_font_size = RcParams.get_rc(rc_params, :get_y_label_font_size)

  #   x_label_offset = x_label_font_size * @pt_to_inch + @padding
  #   y_label_offset = y_label_font_size * @pt_to_inch + @padding

  #   {%Figure{
  #      figure
  #      | axes: %{
  #          axes
  #          | coords: %{
  #              coords
  #              | x_ticks: {xlx + y_label_offset, xly - x_label_offset},
  #                y_ticks: {ylx + y_label_offset, yly - x_label_offset}
  #            }
  #        }
  #    }, {width - x_label_offset, height - y_label_offset}}
  # end

  # defp peel_title_offset(
  #        {%Figure{
  #           rc_params: rc_params,
  #           axes: %{title: title, coords: %Coords{title: {tx, ty}} = coords} = axes
  #         } = figure, {width, height}}
  #      ) do
  #   title_font_size = RcParams.get_rc(rc_params, :get_title_font_size)

  #   title_offset = title_font_size * @pt_to_inch + @padding
  #   top_left = {tx, ty - title_offset}

  #   {%Figure{figure | axes: %{axes | title: %{title | height: title_offset * @dpi}, coords: %Coords{coords | top_left: {tlx, tly}}}}, {width, height - title_offset}}
  # end

  defp ytick_offset(y_ticks, font_size) do
    tick_size = y_ticks |> Enum.max_by(fn tick -> tick_length(tick) end) |> tick_length()
    font_size * @pt_to_inch * tick_size + @tick_line_offset + @padding
  end

  defp xtick_offset(font_size) do
    label_offset(font_size) + @tick_line_offset
  end

  # defp peel_tick_offsets(
  #        {%Figure{
  #           rc_params: rc_params,
  #           axes: %{tick: %{y: y_ticks}, coords: %Coords{x_ticks: {xtx, _}} = coords} = axes,
  #           margin: margin,
  #           figsize: {_width, figheight}
  #         } = figure, {width, height}}
  #      ) do
  #   tick_size = y_ticks |> Enum.max_by(fn tick -> tick_length(tick) end) |> tick_length()
  #   y_tick_font_size = RcParams.get_rc(rc_params, :get_y_tick_font_size)
  #   x_tick_font_size = RcParams.get_rc(rc_params, :get_x_tick_font_size)
  #   y_tick_offset = y_tick_font_size * @pt_to_inch * tick_size
  #   x_tick_offset = x_tick_font_size * @pt_to_inch

  #   {%Figure{
  #      figure
  #      | axes: %{
  #          axes
  #          | coords: %Coords{coords | title: {(xtx + x_tick_offset) * @dpi, figheight * margin * @dpi}}
  #        }
  #    }, {width - y_tick_offset, height - x_tick_offset}}
  # end

  defp tick_length(tick) when is_integer(tick) do
    tick |> Integer.to_string() |> String.length()
  end

  defp tick_length(tick) when is_binary(tick) do
    String.length(tick)
  end

  defp tick_length(tick) when is_float(tick) do
    tick |> Float.to_string() |> String.length()
  end

  defp generate_yticks(%Figure{axes: %module{} = axes} = figure) do
    %Figure{figure | axes: module.generate_yticks(axes)}
  end

  defp generate_xticks(%Figure{axes: %module{} = axes} = figure) do
    %Figure{figure | axes: module.generate_xticks(axes)}
  end
end
