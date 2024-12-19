defmodule Matplotex.Figure.Cast do
  alias Matplotex.Figure.Lead
  alias Matplotex.Element.Legend
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
  alias Matplotex.Figure.Dataset
  @tickline_offset 5 / 96
  @xtick_type "figure.x_tick"
  @ytick_type "figure.y_tick"
  @stroke_grid "#ddd"
  @stroke_width_grid 1
  @lowest_tick 0
  @zero_to_move 0

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
      Algebra.transform_given_point(content_width, content_height, content_x, content_y, 0)
      |> Algebra.flip_y_coordinate()

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
    {lx, by} = Algebra.flip_y_coordinate({lx, by})
    {rx, ty} = Algebra.flip_y_coordinate({rx, ty})
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
              region_title: region_title,
              title: title,
              element: elements
            } = axes,
          rc_params: %RcParams{title_font: title_font}
        } = figure
      ) do
    {ttx, tty} = calculate_center(region_title, :x)

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
              region_title: region_title,
              title: title,
              element: elements
            } = axes,
          rc_params: %RcParams{title_font: title_font, label_padding: title_padding}
        } = figure
      ) do
    {title_x, title_y} = region_title |> calculate_center(:x) |> Algebra.flip_y_coordinate()

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
    {x_label_x, x_label_y} = region_x |> calculate_center(:x) |> Algebra.flip_y_coordinate()

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
    {y_label_x, y_label_y} = region_y |> calculate_center(:y) |> Algebra.flip_y_coordinate()

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
            %{
              tick: %{x: x_ticks},
              limit: %{x: {_min, _max} = xlim},
              region_x:
                %Region{
                  x: x_region_x,
                  y: y_region_x,
                  height: height_region_x,
                  width: width_region_x,
                  coords: %XyCoords{ticks: {_, y_x_tick}} = coords_region_x
                } = region_x,
              data: {x_data, y_data},
              dataset: dataset,
              element: elements,
              show_x_ticks: true
            } = axes,
          rc_params: %RcParams{
            x_tick_font: x_tick_font,
            x_padding: x_padding,
            tick_line_length: tick_line_length,
            white_space: white_space
          }
        } = figure
      )
      when is_list(x_ticks) do
    x_ticks = confine_ticks(x_ticks, xlim)
    x_data = confine_data(x_data, xlim)
    dataset = confine_data(dataset, xlim, :x)
    x_padding_value = width_region_x * x_padding + white_space
    shrinked_width_region_x = width_region_x - x_padding_value * 2
    x_region_x_with_padding = x_region_x + x_padding_value

    ticks_width_position =
      x_ticks
      |> length()
      |> content_linespace(shrinked_width_region_x)
      |> Enum.zip(x_ticks)

    {x_tick_elements, vgrid_coords} =
      Enum.map(ticks_width_position, fn {tick_position, label} ->
        {_, y_x_tick_line} =
          @zero_to_move
          |> Algebra.transform_given_point(height_region_x, x_region_x, y_region_x)
          |> Algebra.flip_y_coordinate()

        {x_x_tick, y_x_tick} =
          tick_position
          |> Algebra.transform_given_point(
            @zero_to_move,
            x_region_x_with_padding,
            y_x_tick
          )
          |> Algebra.flip_y_coordinate()

        label =
          %Label{
            type: @xtick_type,
            x: x_x_tick,
            y: y_x_tick,
            text: format_tick_label(label)
          }
          |> Label.cast_label(x_tick_font)

        line = %Line{
          type: @xtick_type,
          x1: x_x_tick,
          y1: y_x_tick_line,
          x2: x_x_tick,
          y2: y_x_tick_line + tick_line_length
        }

        {%Tick{type: @xtick_type, tick_line: line, label: label}, {x_x_tick, y_x_tick_line}}
      end)
      |> Enum.unzip()

    elements = elements ++ x_tick_elements

    %Figure{
      figure
      | axes: %{
          axes
          | data: {x_data, y_data},
            dataset: dataset,
            element: elements,
            region_x: %Region{region_x | coords: %XyCoords{coords_region_x | grids: vgrid_coords}}
        }
    }
  end

  def cast_xticks_by_region(figure), do: figure
  defp format_tick_label({label, _index}), do: label
  defp format_tick_label(label) when is_float(label), do: Float.round(label, 2)
  defp format_tick_label(label), do: label

  defp content_linespace(number_of_ticks_required, axis_size) do
    @lowest_tick |> Nx.linspace(axis_size, n: number_of_ticks_required) |> Nx.to_list()
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
            %{
              tick: %{y: y_ticks},
              region_y:
                %Region{
                  x: x_region_y,
                  y: y_region_y,
                  width: width_region_y,
                  height: height_region_y,
                  coords: %XyCoords{ticks: {x_y_tick, _}} = coords_region_y
                } = region_y,
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

    y_padding_value = height_region_y * y_padding
    shrinked_height_region_y = height_region_y - y_padding_value * 2
    y_region_y_with_padding = y_region_y + y_padding_value

    ticks_width_position =
      y_ticks
      |> length()
      |> content_linespace(shrinked_height_region_y)
      |> Enum.zip(y_ticks)

    {ytick_elements, hgrid_coords} =
      Enum.map(ticks_width_position, fn {tick_position, label} ->
        {x_y_tick_line, _} =
          Algebra.transform_given_point(width_region_y, @zero_to_move, x_region_y, y_region_y)

        {x_y_tick, y_y_tick} =
          @zero_to_move
          |> Algebra.transform_given_point(
            tick_position,
            x_y_tick,
            y_region_y_with_padding
          )
          |> Algebra.flip_y_coordinate()

        label =
          %Label{
            type: @ytick_type,
            y: y_y_tick,
            x: x_y_tick,
            text: format_tick_label(label)
          }
          |> Label.cast_label(y_tick_font)

        line = %Line{
          type: @ytick_type,
          y1: y_y_tick,
          x1: x_y_tick_line,
          x2: x_y_tick_line - tick_line_length,
          y2: y_y_tick
        }

        {%Tick{type: @ytick_type, tick_line: line, label: label}, {x_y_tick_line, y_y_tick}}
      end)
      |> Enum.unzip()

    elements = elements ++ ytick_elements

    %Figure{
      figure
      | axes: %{
          axes
          | data: {x_data, y_data},
            dataset: dataset,
            element: elements,
            region_y: %Region{region_y | coords: %XyCoords{coords_region_y | grids: hgrid_coords}}
        }
    }
  end

  def cast_yticks_by_region(figure), do: figure

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
              region_x: %Region{width: width_region_x},
              element: elements
            } = axes
        } = figure
      ) do
    hgrid_elements =
      Enum.map(hgrids, fn {x, y} ->
        %Line{
          x1: x,
          x2: x + width_region_x,
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

  def cast_hgrids_by_region(figure), do: figure

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
              region_y: %Region{height: height_region_y},
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
          y2: y - height_region_y,
          type: "figure.v_grid",
          stroke: @stroke_grid,
          stroke_width: @stroke_width_grid
        }
      end)

    elements = elements ++ vgrid_elements

    %Figure{figure | axes: %{axes | element: elements}}
  end

  def cast_vgrids_by_region(figure), do: figure

  def cast_legends(
        %Figure{
          rc_params: %RcParams{legend_font: legend_font, x_padding: padding},
          axes:
            %chart{
              dataset: datasets,
              element: elements,
              show_legend: true,
              region_legend: %Region{
                x: x_region_legend,
                y: y_region_legend,
                width: width_region_legend
              }
            } = axes
        } = figure
      ) do
    space_for_one_line = Lead.height_required_for_text(legend_font, "")
    padding = padding * width_region_legend

    legend_elements =
      datasets
      |> Enum.with_index()
      |> Enum.map(fn {%Dataset{color: color, label: label} = dataset, idx} ->
        {x_region_legend, y_region_legend} =
          Algebra.transform_given_point(
            x_region_legend,
            y_region_legend,
            padding,
            -idx * space_for_one_line - padding
          )
          |> Algebra.flip_y_coordinate()

        %Legend{
          type: "figure.legend",
          x: x_region_legend,
          y: y_region_legend,
          color: color,
          label: label,
          width: space_for_one_line - padding,
          height: space_for_one_line - padding
        }
        |> Legend.with_label(legend_font, padding)
        |> chart.with_legend_handle(dataset)
      end)

    %Figure{figure | axes: %{axes | element: elements ++ legend_elements}}
  end

  def cast_legends(figure), do: figure

  defp plotify_tick(module, {label, value}, lim, axis_size, transition, data, axis) do
    {module.plotify(value, lim, axis_size, transition, data, axis), label}
  end

  defp plotify_tick(module, value, lim, axis_size, transition, data, axis) do
    {module.plotify(value, lim, axis_size, transition, data, axis), value}
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

  defp confine_ticks(ticks, {min, max}) do
    ticks
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

  # defp append_lim([first | [second | _]] = ticks, {min, max}) do
  #   with_min =
  #     if Enum.min(ticks) > min + (second - first) do
  #       [min] ++ ticks
  #     else
  #       ticks
  #     end

  #   if Enum.max(with_min) < max - (second - first) do
  #     with_min ++ [max]
  #   else
  #     with_min
  #   end
  # end
end
