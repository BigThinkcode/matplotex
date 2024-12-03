defmodule Matplotex.Figure.Cast do
  alias Matplotex.Utils.Algebra
  alias Matplotex.Figure.Areal.XyRegion.Coords, as: XyCoords
  alias Matplotex.Figure.Areal.Region
  alias Matplotex.Figure.Dataset
  alias Matplotex.Element.Tick
  alias Matplotex.Figure.RcParams
  alias Matplotex.Element.Label
  alias Matplotex.Element.Line
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure
  @tickline_offset 5 / 96
  @xtick_type "figure.x_tick"
  @ytick_type "figure.y_tick"
  @stroke_grid "#ddd"
  @stroke_width_grid 1

  def cast_spines(
        %Figure{
          axes:
            %{
              coords: %Coords{
                bottom_left: {blx, bly},
                bottom_right: {brx, bry},
                top_left: {tlx, tly},
                top_right: {trx, yrt}
              },
              element: elements
            } = axes
        } = figure
      ) do
    # Four Line struct representing each corners
    left = %Line{
      x1: blx,
      y1: bly,
      x2: tlx,
      y2: tly,
      type: "spine.left"
    }

    right = %Line{
      x1: brx,
      y1: bry,
      x2: trx,
      y2: yrt,
      type: "spine.right"
    }

    top = %Line{
      x1: tlx,
      y1: tly,
      x2: trx,
      y2: yrt,
      type: "spine.top"
    }

    bottom = %Line{
      x1: blx,
      y1: bly,
      x2: brx,
      y2: bry,
      type: "spine.bottom"
    }

    %Figure{figure | axes: %{axes | element: elements ++ [left, right, top, bottom]}}
  end

  def cast_spines(_figure) do
    raise ArgumentError, message: "Figure does't contain enough data to proceed"
  end

  def cast_spines_by_region(
        %Figure{
          axes:
            %{
              region_content: %Region{
                x: content_x,
                y: content_y,
                width: content_width,
                height: content_height
              },
              element: elements
            } = axes
        } = figure
      ) do
    #  Convert to the svg plane

    {left_x, bottom_y} = Algebra.flip_y_coordinate({content_x, content_y})

     {right_x, top_y} =
      Algebra.transform_given_point(content_width, content_height, content_x, content_y, 0)|>Algebra.flip_y_coordinate()
    # Four Line struct representing each corners

    left = %Line{
      x1: left_x,
      y1: bottom_y,
      x2: left_x,
      y2: top_y,
      type: "spine.left"
    }

    right = %Line{
      x1: right_x,
      y1: bottom_y,
      x2: right_x,
      y2: top_y,
      type: "spine.right"
    }

    top = %Line{
      x1: left_x,
      y1: top_y,
      x2: right_x,
      y2: top_y,
      type: "spine.top"
    }

    bottom = %Line{
      x1: left_x,
      y1: bottom_y,
      x2: right_x,
      y2: bottom_y,
      type: "spine.bottom"
    }

    %Figure{figure | axes: %{axes | element: elements ++ [left, right, top, bottom]}}
  end

  def cast_spines_by_region(figure), do: figure

  def cast_border(
        %Figure{
          axes: %{border: {lx, by, rx, ty}, element: element} = axes,
          rc_params: %RcParams{line_width: line_width}
        } = figure
      ) do
    left = %Line{x1: lx, y1: by, x2: lx, y2: ty, type: "border.left", stroke_width: line_width}
    right = %Line{x1: rx, y1: by, x2: rx, y2: ty, type: "border.right", stroke_width: line_width}
    top = %Line{x1: lx, x2: rx, y1: ty, y2: ty, type: "border.top", stroke_width: line_width}

    bottom = %Line{
      x1: lx,
      x2: rx,
      y1: by,
      y2: by,
      type: "border.bottom",
      stroke_width: line_width
    }

    %Figure{figure | axes: %{axes | element: element ++ [left, right, top, bottom]}}
  end

  def cast_title(
        %Figure{
          axes:
            %{
              coords: %Coords{title: title_coord} = coords,
              title: title,
              element: elements
            } = axes,
          rc_params: %RcParams{title_font: title_font}
        } = figure
      ) do
    {ttx, tty} = calculate_center(coords, title_coord, :x)

    title =
      %Label{
        type: "figure.title",
        x: ttx,
        y: tty,
        text: title
      }
      |> merge_structs(title_font)

    %Figure{figure | axes: %{axes | element: elements ++ [title]}}
  end

  def cast_title(%Figure{axes: %{show_title: false}} = figure), do: figure

  def cast_title(_figure) do
    raise ArgumentError, message: "Invalid figure to cast title"
  end

  def cast_title_by_region(
        %Figure{
          axes:
            %{
              region_title: region,
              title: title,
              element: elements
            } = axes,
          rc_params: %RcParams{title_font: title_font, label_padding: title_padding}
        } = figure
      ) do
   {title_x, title_y} = region|>calculate_center(:x)|>Algebra.flip_y_coordinate()
    title =
      %Label{
        type: "figure.title",
        x: title_x,
        y: title_y + title_padding,
        text: title
      }
      |> Label.cast_label(title_font)

    %Figure{figure | axes: %{axes | element: elements ++ [title]}}
  end

  def cast_label(%Figure{axes: %{label: nil}} = figure), do: figure

  def cast_label(figure) do
    figure
    |> cast_xlabel()
    |> cast_ylabel()
  end

  def cast_label_by_region(figure) do
    figure
    |> cast_xlabel_by_region()
    |> cast_ylabel_by_region()
  end

  def cast_xlabel(
        %Figure{
          axes: %{label: %{x: x_label}, coords: coords, element: element} = axes,
          rc_params: %RcParams{x_label_font: label_font}
        } = figure
      )
      when not is_nil(x_label) do
    xlabel_coords = Map.get(coords, :x_label)
    {x, y} = calculate_center(coords, xlabel_coords, :x)

    x_label =
      %Label{
        type: "figure.x_label",
        x: x,
        y: y,
        text: x_label
      }
      |> merge_structs(label_font)

    element = element ++ [x_label]
    %Figure{figure | axes: %{axes | element: element}}
  end

  def cast_xlabel(figure), do: figure

  def cast_xlabel_by_region(
        %Figure{
          axes: %{label: %{x: x_label}, region_x: region_x, element: element} = axes,
          rc_params: %RcParams{x_label_font: x_label_font}
        } = figure
      )
      when not is_nil(x_label) do
    # {_, x_label_y} = Region.get_label_coords(region_x)
    {x_label_x, x_label_y} = region_x|>calculate_center(:x)|>Algebra.flip_y_coordinate()

    x_label =
      %Label{
        type: "figure.x_label",
        x: x_label_x,
        y: x_label_y,
        text: x_label
      }
      |> Label.cast_label(x_label_font)

    element = element ++ [x_label]
    %Figure{figure | axes: %{axes | element: element}}
  end

  def cast_ylabel(
        %Figure{
          axes: %{label: %{y: y_label}, coords: coords, element: element} = axes,
          rc_params: %RcParams{y_label_font: label_font}
        } = figure
      )
      when not is_nil(y_label) do
    ylabel_coords = Map.get(coords, :y_label)

    {x, y} = calculate_center(coords, ylabel_coords, :y)

    y_label =
      %Label{
        type: "figure.y_label",
        x: x,
        y: y,
        text: y_label,
        rotate: rotate_label(:y)
      }
      |> merge_structs(label_font)

    element = element ++ [y_label]
    %Figure{figure | axes: %{axes | element: element}}
  end

  def cast_ylabel(figure), do: figure

  def cast_ylabel_by_region(
        %Figure{
          axes: %{label: %{y: y_label}, region_y: region_y, element: element} = axes,
          rc_params: %RcParams{y_label_font: y_label_font}
        } = figure
      )
      when not is_nil(y_label) do


    {y_label_x, y_label_y} = region_y|>calculate_center(:y)|>Algebra.flip_y_coordinate()
    y_label =
      %Label{
        type: "figure.y_label",
        x: y_label_x,
        y: y_label_y,
        text: y_label,
        rotate: rotate_label(:y)
      }
      |> Label.cast_label(y_label_font)

    element = element ++ [y_label]
    %Figure{figure | axes: %{axes | element: element}}
  end

  def cast_xticks(
        %Figure{
          axes:
            %module{
              tick: %{x: x_ticks},
              limit: %{x: {_min, _max} = xlim},
              size: {width, _height},
              data: {x_data, y_data},
              dataset: dataset,
              element: elements,
              show_x_ticks: true,
              coords: %Coords{bottom_left: {blx, bly}, x_ticks: {_xtx, xty}} = coords
            } = axes,
          rc_params: %RcParams{x_tick_font: tick_font, x_padding: x_padding}
        } = figure
      )
      when is_list(x_ticks) do
    # TODO: Only if it has to confine
    x_ticks = confine_ticks(x_ticks, xlim)
    x_data = confine_data(x_data, xlim)
    dataset = confine_data(dataset, xlim, :x)

    {xtick_elements, vgridxs} =
      Enum.map(x_ticks, fn tick ->
        {tick_position, label} =
          plotify_tick(
            module,
            tick,
            xlim,
            width - width * x_padding * 2,
            blx + width * x_padding,
            x_data,
            :x
          )

        label =
          %Label{
            type: @xtick_type,
            x: tick_position,
            y: xty,
            text: label
          }
          |> merge_structs(tick_font)

        # TODO: find a mechanism to pass custom font for ticks
        line = %Line{
          type: @xtick_type,
          x1: tick_position,
          y1: bly,
          x2: tick_position,
          y2: bly - @tickline_offset
        }

        {%Tick{type: @xtick_type, tick_line: line, label: label}, tick_position}
      end)
      |> Enum.unzip()

    elements = elements ++ xtick_elements
    vgrids = Enum.map(vgridxs, fn g -> {g, bly} end)

    %Figure{
      figure
      | axes: %{
          axes
          | data: {x_data, y_data},
            dataset: dataset,
            element: elements,
            coords: %{coords | vgrids: vgrids}
        }
    }
  end

  def cast_xticks(%Figure{axes: %{tick: %{x: _}, limit: %{x: nil}, show_x_ticks: true}} = figure) do
    figure
    |> set_xlim_from_ticks()
    |> cast_xticks()
  end

  def cast_xticks(%Figure{} = figure), do: figure

  def cast_xticks_by_region(
        %Figure{
          axes:
            %module{
              tick: %{x: x_ticks},
              limit: %{x: {_min, _max} = xlim},
              region_content: %Region{x: x_region_content, width: width_region_content},
              region_x: %Region{coords: coords_region_x} = region_x,
              data: {x_data, y_data},
              dataset: dataset,
              element: elements,
              show_x_ticks: true
            } = axes,
          rc_params: %RcParams{
            x_tick_font: x_tick_font,
            x_padding: x_padding,
            tick_line_length: tick_line_length
          }
        } = figure
      )
      when is_list(x_ticks) do
    x_ticks = confine_ticks(x_ticks, xlim)
    x_data = confine_data(x_data, xlim)
    dataset = confine_data(dataset, xlim, :x)

    {_, x_tick_y} = Region.get_tick_coords(region_x)

    {xtick_elements, vgridxs} =
      Enum.map(x_ticks, fn tick ->
        {tick_position, label} =
          transform_tick(
            module,
            tick,
            xlim,
            width_region_content - width_region_content * x_padding * 2,
            x_region_content + width_region_content * x_padding,
            :x
          )

        x_tick_x = elem(tick_position, 0)

        label =
          %Label{
            type: @xtick_type,
            x: x_tick_x,
            y: x_tick_y,
            text: label
          }
          |> Label.cast_label(x_tick_font)

        line = %Line{
          type: @xtick_type,
          x1: x_tick_x,
          y1: x_tick_y,
          x2: x_tick_x,
          y2: x_tick_y - tick_line_length
        }

        {%Tick{type: @xtick_type, tick_line: line, label: label}, x_tick_x}
      end)
      |> Enum.unzip()

    elements = elements ++ xtick_elements
    vgrids = Enum.map(vgridxs, fn g -> {g, x_tick_y} end)

    %Figure{
      figure
      | axes: %{
          axes
          | data: {x_data, y_data},
            dataset: dataset,
            element: elements,
            region_x: %Region{region_x | coords: %XyCoords{coords_region_x | grids: vgrids}}
        }
    }
  end

  @spec cast_yticks(Matplotex.Figure.t()) :: Matplotex.Figure.t()
  def cast_yticks(
        %Figure{
          axes:
            %module{
              tick: %{y: y_ticks},
              size: {_width, height},
              element: elements,
              coords: %Coords{bottom_left: {blx, bly}, y_ticks: {ytx, _yty}} = coords,
              limit: %{y: {_min, _max} = ylim},
              data: {x_data, y_data},
              dataset: dataset,
              show_y_ticks: true
            } = axes,
          rc_params: %RcParams{y_tick_font: tick_font, y_padding: padding}
        } = figure
      ) do
    y_ticks = confine_ticks(y_ticks, ylim)
    y_data = confine_data(y_data, ylim)
    dataset = confine_data(dataset, ylim, :y)

    {ytick_elements, hgridys} =
      Enum.map(y_ticks, fn tick ->
        {tick_position, label} =
          plotify_tick(
            module,
            tick,
            ylim,
            height - height * padding * 2,
            bly + height * padding,
            y_data,
            :y
          )

        label =
          %Label{
            type: @ytick_type,
            y: tick_position,
            x: ytx,
            text: label,
            text_anchor: "end",
            dominant_baseline: "middle"
          }
          |> merge_structs(tick_font)

        # TODO: find a mechanism to pass custom font for ticks
        line = %Line{
          type: @ytick_type,
          y1: tick_position,
          x1: blx,
          x2: blx - @tickline_offset,
          y2: tick_position
        }

        {%Tick{type: @ytick_type, tick_line: line, label: label}, tick_position}
      end)
      |> Enum.unzip()

    elements = elements ++ ytick_elements
    hgrids = Enum.map(hgridys, fn g -> {blx, g} end)

    %Figure{
      figure
      | axes: %{
          axes
          | data: {x_data, y_data},
            dataset: dataset,
            element: elements,
            coords: %{coords | hgrids: hgrids}
        }
    }
  end

  def cast_yticks(%Figure{axes: %{tick: %{y: _}, limit: %{y: nil}, show_y_ticks: true}} = figure) do
    figure
    |> set_ylim_from_ticks()
    |> cast_yticks()
  end

  def cast_ytick(%Figure{} = figure), do: figure

  def cast_yticks_by_region(
        %Figure{
          axes:
            %module{
              tick: %{y: y_ticks},
              region_content: %Region{
                x: x_region_content,
                y: y_region_content,
                height: height_region_content
              },
              region_y: %Region{coords: coords_region_y} = region_y,
              element: elements,
              limit: %{y: {_min, _max} = ylim},
              data: {x_data, y_data},
              dataset: dataset,
              show_y_ticks: true
            } = axes,
          rc_params: %RcParams{
            y_tick_font: y_tick_font,
            y_padding: y_padding,
            tick_line_length: tick_line_length
          }
        } = figure
      ) do
    y_ticks = confine_ticks(y_ticks, ylim)
    y_data = confine_data(y_data, ylim)
    dataset = confine_data(dataset, ylim, :y)
    {y_tick_x, _} = Region.get_tick_coords(region_y)

    {ytick_elements, hgridys} =
      Enum.map(y_ticks, fn tick ->
        {tick_position, label} =
          transform_tick(
            module,
            tick,
            ylim,
            height_region_content - height_region_content * y_padding * 2,
            y_region_content + height_region_content * y_padding,
            :y
          )

        y_tick_y = elem(tick_position, 1)

        label =
          %Label{
            type: @ytick_type,
            y: y_tick_y,
            x: y_tick_x,
            text: label,
            text_anchor: "end",
            dominant_baseline: "middle"
          }
          |> Label.cast_label(y_tick_font)

        line = %Line{
          type: @ytick_type,
          y1: y_tick_y,
          x1: x_region_content,
          x2: x_region_content - tick_line_length,
          y2: y_tick_y
        }

        {%Tick{type: @ytick_type, tick_line: line, label: label}, y_tick_y}
      end)
      |> Enum.unzip()

    elements = elements ++ ytick_elements
    hgrids = Enum.map(hgridys, fn g -> {x_region_content, g} end)

    %Figure{
      figure
      | axes: %{
          axes
          | data: {x_data, y_data},
            dataset: dataset,
            element: elements,
            region_y: %Region{region_y | coords: %XyCoords{coords_region_y | grids: hgrids}}
        }
    }
  end

  def cast_hgrids(%Figure{axes: %{coords: %{hgrids: nil}}} = figure), do: figure
  def cast_hgrids(%Figure{axes: %{show_h_grid: false}} = figure), do: figure

  def cast_hgrids(
        %Figure{
          axes:
            %{
              show_h_grid: true,
              coords: %Coords{hgrids: hgrids, top_right: {rightx, _topy}},
              element: elements
            } = axes
        } = figure
      ) do
    hgrid_elements =
      Enum.map(hgrids, fn {x, y} ->
        %Line{
          x1: x,
          x2: rightx,
          y1: y,
          y2: y,
          type: "figure.h_grid",
          stroke: @stroke_grid,
          stroke_width: @stroke_width_grid
        }
      end)

    elements = elements ++ hgrid_elements

    %Figure{figure | axes: %{axes | element: elements}}
  end

  def cast_hgrids_by_region(
        %Figure{
          axes:
            %{
              show_h_grid: true,
              region_y: %Region{coords: %XyCoords{grids: hgrids}},
              region_content: %Region{x: x_region_content, width: width_region_content},
              element: elements
            } = axes
        } = figure
      ) do
    hgrid_elements =
      Enum.map(hgrids, fn {_x, y} ->
        %Line{
          x1: x_region_content,
          x2: x_region_content + width_region_content,
          y1: y,
          y2: y,
          type: "figure.h_grid",
          stroke: @stroke_grid,
          stroke_width: @stroke_width_grid
        }
      end)

    elements = elements ++ hgrid_elements

    %Figure{figure | axes: %{axes | element: elements}}
  end

  def cast_vgrids(%Figure{axes: %{coords: %{vgrids: nil}}} = figure), do: figure
  def cast_vgrids(%Figure{axes: %{show_v_grid: false}} = figure), do: figure

  def cast_vgrids(
        %Figure{
          axes:
            %{
              show_v_grid: true,
              coords: %Coords{vgrids: vgrids, top_right: {_rightx, topy}},
              element: elements
            } = axes
        } = figure
      ) do
    vgrid_elements =
      Enum.map(vgrids, fn {x, y} ->
        %Line{
          x1: x,
          x2: x,
          y1: y,
          y2: topy,
          type: "figure.v_grid",
          stroke: @stroke_grid,
          stroke_width: @stroke_width_grid
        }
      end)

    elements = elements ++ vgrid_elements

    %Figure{figure | axes: %{axes | element: elements}}
  end

  def cast_vgrids_by_region(
        %Figure{
          axes:
            %{
              show_v_grid: true,
              region_x: %Region{coords: %XyCoords{grids: vgrids}},
              region_content: %Region{y: y_region_content, height: height_region_content},
              element: elements
            } = axes
        } = figure
      ) do
    vgrid_elements =
      Enum.map(vgrids, fn {x, _y} ->
        %Line{
          x1: x,
          x2: x,
          y1: y_region_content,
          y2: y_region_content + height_region_content,
          type: "figure.v_grid",
          stroke: @stroke_grid,
          stroke_width: @stroke_width_grid
        }
      end)

    elements = elements ++ vgrid_elements

    %Figure{figure | axes: %{axes | element: elements}}
  end

  # def cast_region_x(
  #   %Figure{axes: %{ label: %TwoD{x: x_label},tick: %TwoD{x: x_ticks},
  #   region_x: %Region{x: x_region_x, y: x_region_y, width: width, height: height,
  #   coords: %XyCoords{label: {x_label_x, x_label_y}, ticks: x_tick_coords}},
  #   rc_params: %RcParams{x_label_font: x_label_font}} = axes} = figure) do

  #   xlabel_element = %Label{x: x_label_x, y: x_label_y, text: x_label}|>Label.cast_label(x_label_font)
  #   x_tick_elements =

  # end

  defp plotify_tick(module, {label, value}, lim, axis_size, transition, data, axis) do
    {module.plotify(value, lim, axis_size, transition, data, axis), label}
  end

  defp plotify_tick(module, value, lim, axis_size, transition, data, axis) do
    {module.plotify(value, lim, axis_size, transition, data, axis), value}
  end

  defp transform_tick(module, {label, value}, lim, axis_size, transition, axis) do
    {module.tick_homogeneous_transformation(value, lim, axis_size, transition, axis), label}
  end

  defp transform_tick(module, value, lim, axis_size, transition, axis) do
    {module.tick_homogeneous_transformation(value, lim, axis_size, transition, axis), value}
  end

  defp min_max([{_pos, _label} | _] = ticks) do
    ticks
    |> Enum.min_max_by(fn {_labe, pos} -> pos end)
    |> then(fn {{_label_min, pos_min}, {_label_max, pos_max}} -> {pos_min, pos_max} end)
  end

  defp min_max(ticks) do
    Enum.min_max(ticks)
  end

  defp calculate_center(%Coords{bottom_left: bottom_left, bottom_right: bottom_right}, {x, y}, :x) do
    {calculate_distance(bottom_left, bottom_right) / 2 + x, y}
  end

  defp calculate_center(%Coords{bottom_left: bottom_left, top_left: top_left}, {x, y}, :y) do
    {x, calculate_distance(bottom_left, top_left) / 2 + y}
  end

  defp calculate_center(%Region{x: x, y: y, width: width}, :x) do
    {calculate_distance({x, y}, {x + width, y}) / 2 + x, y}
  end

  defp calculate_center(%Region{x: x, y: y, height: height}, :y) do
    {x, calculate_distance({x, y}, {x, y + height}) / 2 + y}
  end

  defp merge_structs(%module{} = st, sst) do
    sst = Map.from_struct(sst)
    params = st |> Map.from_struct() |> Map.merge(sst)
    struct(module, params)
  end

  defp calculate_distance({x1, y1}, {x2, y2}) do
    :math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
  end

  defp rotate_label(:y), do: -90

  defp set_xlim_from_ticks(%Figure{axes: %module{tick: %{x: xtick}} = axes} = figure) do
    {xmin, xmax} = min_max(xtick)

    xscale = xmax |> round() |> div(length(xtick) - 1)

    xlim = {round(xmin - xscale), round(xmax + xscale)}
    axes = module.set_limit(axes, {:x, xlim})

    %Figure{figure | axes: axes}
  end

  defp set_ylim_from_ticks(%Figure{axes: %module{tick: %{y: ytick}} = axes} = figure) do
    {ymin, ymax} = min_max(ytick)
    yscale = ymax |> round() |> div(length(ytick) - 1)
    ylim = {round(ymin - yscale), round(ymax + yscale)}
    axes = module.set_limit(axes, {:y, ylim})
    %Figure{figure | axes: axes}
  end

  defp confine_ticks([{_l, _v} | _] = ticks, {min, max}) do
    ticks
    |> Enum.filter(fn {_l, tick} ->
      tick >= min && tick <= max
    end)
  end

  defp confine_ticks(ticks, {min, max} = lim) do
    ticks
    |> append_lim(lim)
    |> Enum.filter(fn tick ->
      tick >= min && tick <= max
    end)
  end

  defp confine_data([%Dataset{} | _] = dataset, lim, axis) do
    Enum.map(dataset, fn datas ->
      confined = confine_data(Map.get(datas, axis), lim)
      Map.put(datas, axis, confined)
    end)
  end

  defp confine_data([{_l, _v} | _] = data, {min, max}) do
    confine_ticks(data, {min, max})
  end

  defp confine_data(data, {min, max}) do
    data
    |> Enum.filter(fn tick ->
      tick >= min && tick <= max
    end)
  end

  defp append_lim([first | [second | _]] = ticks, {min, max}) do
    with_min =
      if Enum.min(ticks) > min + (second - first) do
        [min] ++ ticks
      else
        ticks
      end

    if Enum.max(with_min) < max - (second - first) do
      with_min ++ [max]
    else
      with_min
    end
  end
end
