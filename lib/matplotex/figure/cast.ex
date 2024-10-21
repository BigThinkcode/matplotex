defmodule Matplotex.Figure.Cast do
  alias Matplotex.Element.Tick
  alias Matplotex.Figure.RcParams
  alias Matplotex.Element.Label
  alias Matplotex.Element.Line
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure
  @tickline_offset 5 / 96
  @padding 0.05
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
              }
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

    element = [left, right, top, bottom]
    axes = %{axes | element: element}
    %Figure{figure | axes: axes}
  end

  def cast_spines(_figure) do
    raise ArgumentError, message: "Figure does't contain enough data to proceed"
  end

  def cast_title(
        %Figure{
          axes:
            %{
              coords: %Coords{title: title_coord} = coords,
              title: %{text: text},
              element: elements
            } = axes,
          rc_params: rc_params
        } = figure
      ) do
    title_font = rc_params |> RcParams.get_rc(:get_title_font) |> Map.from_struct()

    {ttx, tty} = calculate_center(coords, title_coord, :x)
    title =
      %Label{
        type: "figure.title",
        x: ttx,
        y: tty,
        text: text
      }
      |> merge_structs(title_font)

    %Figure{figure | axes: %{axes | element: elements ++ [title]}}
  end

  def cast_title(%Figure{axes: %{show_title: false}} = figure), do: figure

  def cast_title(_figure) do
    raise ArgumentError, message: "Invalid figure to cast title"
  end

  def cast_label(%Figure{axes: %{label: nil}} = figure), do: figure

  # def cast_label(
  #       %Figure{
  #         axes: %{label: labels, coords: coords, element: element} = axes,
  #         rc_params: rc_params
  #       } = figure
  #     ) do
  #   label_elements =
  #     Enum.map(labels, fn {axis, label} ->
  #       {x, y} = label_coords = Map.get(coords, :"#{axis}_label")
  #       ticks_coords = Map.get(coords, :"#{axis}_ticks")
  #       height = calculate_distance(label_coords, ticks_coords)
  #       width = calculate_width(coords, axis)
  #       label_font = rc_params |> RcParams.get_rc(:"get_#{axis}_label_font") |> Map.from_struct()

  #       %Label{
  #         type: "figure.#{axis}_label",
  #         x: x,
  #         y: y,
  #         text: label,
  #         height: height,
  #         width: width,
  #         rotate: rotate_label(axis)
  #       }
  #       |> merge_structs(label_font)
  #     end)

  #   element = element ++ label_elements
  #   %Figure{figure | axes: %{axes | element: element}}
  # end

  def cast_label(figure) do
    figure
    |> cast_xlabel()
    |> cast_ylabel()
  end

  # def cast_label(_figure) do
  #   raise ArgumentError, message: "Invalid figure to cast label"
  # end

  def cast_xlabel(
        %Figure{
          axes: %{label: %{x: x_label}, coords: coords, element: element} = axes,
          rc_params: rc_params
        } = figure
      ) do
    xlabel_coords = Map.get(coords, :x_label)
    {x,y} = calculate_center(coords,xlabel_coords, :x)
    label_font = rc_params |> RcParams.get_rc(:get_x_label_font) |> Map.from_struct()

    x_label =
      %Label{
        type: "figure.x_label",
        x: x,
        y: y,
        text: x_label,
      }
      |> merge_structs(label_font)

    element = element ++ [x_label]
    %Figure{figure | axes: %{axes | element: element}}
  end

  def cast_ylabel(
        %Figure{
          axes: %{label: %{y: y_label}, coords: coords, element: element} = axes,
          rc_params: rc_params
        } = figure
      ) do
    ylabel_coords = Map.get(coords, :y_label)

    {x,y} = calculate_center(coords,ylabel_coords, :y)
    label_font = rc_params |> RcParams.get_rc(:get_y_label_font) |> Map.from_struct()

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

  def cast_xticks(
        %Figure{
          axes:
            %{
              tick: %{x: x_ticks},
              limit: %{x: {_min, _max} = xlim},
              size: {width, _height},
              element: elements,
              show_x_ticks: true,
              coords: %Coords{bottom_left: {blx, bly}, x_ticks: {_xtx, xty}} = coords
            } = axes
        } = figure
      ) when is_list(x_ticks) do
    x_ticks = confine_tick(x_ticks, xlim)

    {xtick_elements, vgridxs} =
      Enum.map(x_ticks, fn tick ->
        {tick_position, label} =
          plotify_tick(tick, xlim, width - width * @padding, blx + width * @padding)

        label = %Label{
          type: @xtick_type,
          x: tick_position,
          y: xty,
          text: label,
        }

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
    %Figure{figure | axes: %{axes | element: elements, coords: %{coords | vgrids: vgrids}}}
  end
  def cast_xticks(%Figure{axes: %{tick: %{x: nil}, show_x_ticks: true}} = figure) do
    figure
    |>generate_xticks()
    |>cast_xticks()
  end

  def cast_xticks(%Figure{axes: %{tick: %{x: _}, limit: %{x: nil}, show_x_ticks: true}} = figure) do
    figure
    |> set_xlim_from_ticks()
    |> cast_xticks()
  end

  def cast_xticks(%Figure{} = figure), do: figure

  def cast_yticks(
        %Figure{
          axes:
            %{
              tick: %{y: y_ticks},
              size: {_width, height},
              element: elements,
              coords: %Coords{bottom_left: {blx, bly}, y_ticks: {ytx, _yty}} = coords,
              limit: %{y: {_min, _max} = ylim},
              show_y_ticks: true
            } = axes
        } = figure
      ) do
    y_ticks = confine_tick(y_ticks, ylim)

    {ytick_elements, hgridys} =
      Enum.map(y_ticks, fn tick ->
        {tick_position, label} =
          plotify_tick(tick, ylim, height - height * @padding, bly + height * @padding)

        label = %Label{
          type: @ytick_type,
          y: tick_position,
          x: ytx,
          text: label
        }

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
    %Figure{figure | axes: %{axes | element: elements, coords: %{coords | hgrids: hgrids}}}
  end


  def cast_yticks(%Figure{axes: %{tick: %{y: nil}, show_y_ticks: true}} = figure) do
    figure
    |>generate_yticks()
    |>cast_yticks()
  end


  def cast_yticks(%Figure{axes: %{tick: %{y: _}, limit: %{y: nil}, show_y_ticks: true}} = figure) do
    figure
    |> set_ylim_from_ticks()
    |> cast_yticks()
  end

  def cast_ytick(%Figure{} = figure), do: figure

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

  defp plotify_tick({value, label}, lim, axis_size, transition) do
    {plotify(value, lim, axis_size, transition), label}
  end

  defp plotify_tick(value, lim, axis_size, transition) do
    {plotify(value, lim, axis_size, transition), value}
  end

  defp plotify(value, {min, max}, axis_size, transition) do
    s = axis_size / (max - min)
    value * s + transition
  end

  defp min_max([{_pos, _label} | _] = ticks) do
    ticks
    |> Enum.min_max_by(fn {pos, _label} -> pos end)
    |> then(fn {{pos_min, _label_min}, {pos_max, _label_max}} -> {pos_min, pos_max} end)
  end

  defp min_max(ticks) do
    Enum.min_max(ticks)
  end

  defp calculate_center(%Coords{bottom_left: bottom_left, bottom_right: bottom_right},{x,y}, :x) do
    {calculate_distance(bottom_left, bottom_right)/2 + x, y}
  end

  defp calculate_center(%Coords{bottom_left: bottom_left, top_left: top_left},{x, y}, :y) do
    {x,calculate_distance(bottom_left, top_left)/2 + y}
  end

  defp merge_structs(%module{} = st, params) do
    params = st |> Map.from_struct() |> Map.merge(params)
    struct(module, params)
  end

  defp calculate_distance({x1, y1}, {x2, y2}) do
    :math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
  end

  defp rotate_label(:y), do: -90
  defp rotate_label(_), do: nil

  defp set_xlim_from_ticks(%Figure{axes: %module{tick: %{x: xtick}} = axes} = figure) do
    {xmin, xmax} = min_max(xtick)

    xscale = xmax / length(xtick)

    xlim = {round(xmin - xscale), round(xmax + xscale)}

    axes = module.set_limit(axes, {:x, xlim})

    %Figure{figure | axes: axes}
  end

  defp set_ylim_from_ticks(%Figure{axes: %module{tick: %{y: ytick}} = axes} = figure) do
    {ymin, ymax} = min_max(ytick)
    yscale = ymax / length(ytick)
    ylim = {round(ymin - yscale), round(ymax + yscale)}
    axes = module.set_limit(axes, {:y, ylim})
    %Figure{figure | axes: axes}
  end

  defp confine_tick(ticks, {min, max}) do
    Enum.filter(ticks, fn tick ->
      tick > min && tick < max
    end)
  end

  defp generate_xticks(%Figure{axes: %module{} = axes} = figure) do
   %Figure{figure | axes: module.generate_xticks(axes)}
  end
  defp generate_yticks(%Figure{axes: %module{} = axes} = figure) do
    %Figure{figure | axes: module.generate_yticks(axes)}
   end

end
