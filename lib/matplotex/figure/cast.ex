defmodule Matplotex.Figure.Cast do
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
          rc_params: %RcParams{title_font: title_font}
        } = figure
      ) do
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
          rc_params: %RcParams{x_label_font: label_font}
        } = figure
      ) do
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

  def cast_ylabel(
        %Figure{
          axes: %{label: %{y: y_label}, coords: coords, element: element} = axes,
          rc_params: %RcParams{y_label_font: label_font}
        } = figure
      ) do
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
            text: label
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

    xscale = xmax|>round()|>div((length(xtick) - 1))

    xlim = {round(xmin - xscale), round(xmax + xscale)}
    axes = module.set_limit(axes, {:x, xlim})

    %Figure{figure | axes: axes}
  end

  defp set_ylim_from_ticks(%Figure{axes: %module{tick: %{y: ytick}} = axes} = figure) do
    {ymin, ymax} = min_max(ytick)
    yscale = ymax|>round()|>div((length(ytick) - 1))
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
