defmodule Matplotex.Figure.Cast do
  alias Matplotex.Element.Tick
  alias Matplotex.Figure.RcParams
  alias Matplotex.Element.Label
  alias Matplotex.Element.Line
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure
  @dpi 96
  @tickline_offset 5
  @padding 0.05
  @xtick_type "figure.x_tick"
  @ytick_type "figure.y_tick"

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
    left = %Line{x1: to_pixel(blx), y1: to_pixel(bly), x2: to_pixel(tlx), y2: to_pixel(tly), type: "spine.left"}
    right = %Line{x1: to_pixel(brx), y1: to_pixel(bry), x2: to_pixel(trx), y2: to_pixel(yrt), type: "spine.right"}
    top = %Line{x1: to_pixel(tlx), y1: to_pixel(tly), x2: to_pixel(trx), y2: to_pixel(yrt), type: "spine.top"}
    bottom = %Line{x1: to_pixel(blx), y1: to_pixel(bly), x2: to_pixel(brx), y2: to_pixel(bry), type: "spine.bottom"}
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
              coords: %Coords{title: {ttx, tty}, top_left: top_left, top_right: top_right},
              title: %{text: text, height: height},
              element: elements
            } = axes,
          rc_params: rc_params
        } = figure
      ) do
    title_font = rc_params |> RcParams.get_rc(:get_title_font) |> Map.from_struct()

    width = calculate_distance(top_left, top_right)

    title =
      %Label{type: "figure.title", x: to_pixel(ttx), y: to_pixel(tty), text: text, height: height, width: width}
      |> merge_structs(title_font)

    %Figure{figure | axes: %{axes | element: elements ++ [title]}}
  end

  def cast_title(%Figure{axes: %{show_title: false}} = figure), do: figure

  def cast_title(_figure) do
    raise ArgumentError, message: "Invalid figure to cast title"
  end

  def cast_label(%Figure{axes: %{label: labels, coords: coords, element: element} = axes, rc_params: rc_params} = figure) do
    label_elements =  Enum.map(labels, fn {axis, label} ->
      {x, y} = label_coords = Map.get(coords, :"#{axis}_label")
        ticks_coords = Map.get(coords, :"#{axis}_ticks")
        height =  calculate_distance(label_coords,ticks_coords)
        width = calculate_width(coords, axis)
        label_font = rc_params|>RcParams.get_rc(:"get_#{axis}_label_font")|>Map.from_struct()
      %Label{type: "figure.#{axis}_label", x: to_pixel(x), y: to_pixel(y), text: label, height: to_pixel(height), width: to_pixel(width)}|>merge_structs(label_font)
     end )
     element = element ++ label_elements
     %Figure{figure | axes: %{axes | element: element}}
  end
  def cast_label(_figure) do
    raise ArgumentError, message: "Invalid figure to cast label"
  end

  def cast_xticks(%Figure{axes: %{tick: %{x: x_ticks},size: {width, _height}, element: elements, coords: %Coords{bottom_left: {blx, bly}, x_ticks: {_xtx, xty}} = coords} = axes} = figure) do
  {xtick_elements, vgridxs} = Enum.map(x_ticks, fn tick->
   {tick_position, label} =  plotify_tick(tick, x_ticks, width, blx + width * @padding )
   label = %Label{type: @xtick_type,x: tick_position, y: xty, text: label}
   #TODO: find a mechanism to pass custom font for ticks
   line = %Line{type: @xtick_type,x1: tick_position, y1: bly, x2: tick_position, y2: bly - @tickline_offset }
   {%Tick{type: @xtick_type, tick_line: line, label: label}, tick_position}
  end)
  |>Enum.unzip()
  elements = elements ++ xtick_elements
  vgrids = Enum.map(vgridxs, fn g -> {g, bly} end)
  %Figure{figure | axes: %{axes | element: elements, coords: %{coords | vgrids: vgrids}}}
  end

  def cast_yticks(%Figure{axes: %{tick: %{y: y_ticks},size: {_width, height}, element: elements, coords: %Coords{bottom_left: {blx, bly}, y_ticks: {ytx, yty}} = coords} = axes} = figure) do
    {ytick_elements, hgridys} = Enum.map(y_ticks, fn tick->
     {tick_position, label} =  plotify_tick(tick, y_ticks, height, bly + height * @padding )
     label = %Label{type: @ytick_type,y: tick_position, x: ytx, text: label}
     #TODO: find a mechanism to pass custom font for ticks
     line = %Line{type: @ytick_type,y1: tick_position,x1: blx, x2: blx - @tickline_offset, y2: tick_position }
     {%Tick{type: @ytick_type, tick_line: line, label: label}, tick_position}
    end)
    |>Enum.unzip()
    elements = elements ++ ytick_elements
    hgrids = Enum.map(hgridys, fn g -> {blx, g} end)
    %Figure{figure | axes: %{axes | element: elements, coords: %{coords | hgrids: hgrids}}}
    end
  defp plotify_tick({value, label}, ticks, axis_size, transition ) do
    minmax  = min_max(ticks)
    {plotify(value, minmax, axis_size,transition), label}
  end
  defp plotify_tick(value, ticks, axis_size, transition) do
    {plotify(value, min_max(ticks), axis_size, transition), value}
  end
  defp plotify(value, {min, max}, axis_size, transition ) do
    s = axis_size / (max - min)
    value * s  + transition
  end

  defp min_max([{_pos, _label} | _] = ticks) do
    ticks
    |> Enum.min_max_by(fn {pos, _label} -> pos end )
    |> then(fn {{pos_min, _label_min}, {pos_max, _label_max}} -> {pos_min, pos_max} end)
  end
  defp min_max(ticks) do
    Enum.min_max(ticks)
  end

  defp calculate_width(%Coords{bottom_left: bottom_left, bottom_right: bottom_right}, :x) do
    calculate_distance(bottom_left,bottom_right)
  end

  defp calculate_width(%Coords{bottom_left: bottom_left, top_left: top_left}, :y) do
    calculate_distance(bottom_left,top_left)
  end

  defp merge_structs(%module{} = st, params) do
    params = st |> Map.from_struct() |> Map.merge(params)
    struct(module, params)
  end

  defp calculate_distance({x1, y1}, {x2, y2}) do
    :math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
  end
  defp to_pixel(inch), do: inch * @dpi
end
