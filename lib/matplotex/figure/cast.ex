defmodule Matplotex.Figure.Cast do
  @moduledoc false
  alias Matplotex.Element.Rect
  alias Matplotex.Element.Cmap
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
  # alias Matplotex.Figure.Coords
  alias Matplotex.Figure
  alias Matplotex.Figure.Dataset
  @xtick_type "figure.x_tick"
  @ytick_type "figure.y_tick"
  @lowest_tick 0
  @zero_to_move 0
  @cmap_id "colorGradient"

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

  def cast_label_by_region(figure) do
    figure
    |> cast_xlabel_by_region()
    |> cast_ylabel_by_region()
  end

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

  def cast_xlabel_by_region(figure), do: figure

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

  def cast_ylabel_by_region(figure), do: figure

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

  def cast_hgrids_by_region(
        %Figure{
          axes:
            %{
              show_h_grid: true,
              stroke_grid: stroke_grid,
              stroke_grid_width: stroke_grid_width,
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
          stroke: stroke_grid,
          stroke_width: stroke_grid_width
        }
      end)

    elements = elements ++ hgrid_elements

    %Figure{figure | axes: %{axes | element: elements}}
  end

  def cast_hgrids_by_region(figure), do: figure

  def cast_vgrids_by_region(
        %Figure{
          axes:
            %{
              show_v_grid: true,
              stroke_grid: stroke_grid,
              stroke_grid_width: stroke_grid_width,
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
          stroke: stroke_grid,
          stroke_width: stroke_grid_width
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

  def cast_legends(
        %Figure{
          axes:
            %{
              dataset: datasets,
              element: elements,
              cmap: cmap,
              region_legend: %Region{
                x: x_region_legend,
                y: y_region_legend,
                width: width_region_legend
              },
              region_content: %Region{
                height: height_region_content
              }
            } = axes,
          rc_params: %RcParams{
            cmap_width: cmap_width,
            cmap_tick_font: cmap_tick_font,
            tick_line_length: tick_line_length,
            padding: padding
          }
        } = figure
      )
      when is_list(cmap) do
    cmap_elements =
      datasets
      |> Enum.with_index()
      |> Enum.map(fn {%Dataset{colors: colors, cmap: cmap}, idx} ->
        cmap_padding = width_region_legend * padding * 4
        {start, stop} = Enum.min_max(colors)
        tick_labels = Nx.linspace(start, stop, n: 4) |> Nx.to_list()

        {x_cmap, y_cmap} =
          cmap_coords =
          Algebra.transform_given_point(
            x_region_legend,
            y_region_legend,
            idx * cmap_width,
            0
          )
          |> Algebra.transform_given_point({cmap_padding, 0})

        unit_size = height_region_content / 5

        ticks =
          tick_labels
          |> Enum.with_index()
          |> Enum.map(fn {tick, idx} ->
            position_on_bar = (idx + 1) * unit_size

            tick_coords =
              {x_cmap_tick, y_cord_tick} =
              {x_cmap, y_cmap}
              |> Algebra.transform_given_point({cmap_width, position_on_bar})
              |> Algebra.flip_y_coordinate()
              |> Algebra.transform_given_point({0, height_region_content})

            {x2_cmap_tick, _} =
              tick_x2 = Algebra.transform_given_point(tick_coords, {tick_line_length, 0})

            {tick_label_x, _} = Algebra.transform_given_point(tick_x2, {tick_line_length, 0})

            tick_label =
              Label.cast_label(
                %Label{
                  type: "tick.cmap",
                  x: tick_label_x,
                  y: y_cord_tick,
                  text: format_tick_label(tick)
                },
                cmap_tick_font
              )

            %Tick{
              type: "tick.cmap",
              tick_line: %Line{
                type: "tick.cmap",
                x1: x_cmap_tick,
                x2: x2_cmap_tick,
                y1: y_cord_tick,
                y2: y_cord_tick
              },
              label: tick_label
            }
          end)

        {x_cmap, y_cmap} = Algebra.flip_y_coordinate(cmap_coords)

        [
          %Cmap{
            id: @cmap_id,
            cmap: cmap,
            container: %Rect{
              x: x_cmap,
              y: y_cmap,
              width: cmap_width,
              height: height_region_content
            }
          }
          |> Cmap.color_gradient()
        ] ++ ticks
      end)
      |> List.flatten()

    %Figure{figure | axes: %{axes | element: elements ++ cmap_elements}}
  end

  def cast_legends(figure), do: figure

  defp calculate_center(%Region{x: x, y: y, width: width}, :x) do
    {calculate_distance({x, y}, {x + width, y}) / 2 + x, y}
  end

  defp calculate_center(%Region{x: x, y: y, height: height}, :y) do
    {x, calculate_distance({x, y}, {x, y + height}) / 2 + y}
  end

  defp calculate_distance({x1, y1}, {x2, y2}) do
    :math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
  end

  defp rotate_label(:y), do: -90

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
end
