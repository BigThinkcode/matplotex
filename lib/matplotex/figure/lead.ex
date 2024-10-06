defmodule Matplotex.Figure.Lead do
  alias Matplotex.Element.Label
  alias Matplotex.Figure.Coords
  alias Matplotex.Element.Line
  alias Matplotex.Figure.RcParams
  alias Matplotex.Figure
  @pt_to_inch 1 / 72
  @dpi 96

  def set_spines(%Figure{} = figure) do
    # {{width, height}, {bottom_left, top_left, bottom_right, top_right}} =
    {%Figure{axes: axes}, {width, height}} =
      figure
      |> peel_margin()
      |> peel_label_offsets()
      |> peel_title_offsets()
      |> peel_tick_offsets()
      |> calculate_corners()
      |> peel_margin()

    axes = %{
      axes
      | size: %{width: width * @dpi, height: height * @dpi}
    }

    %Figure{figure | axes: axes}
  end

  def set_spines(_) do
    raise ArgumentError, message: "Invalid figure to proceed"
  end

  def draw_spines(
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
    left = %Line{x1: blx, y1: bly, x2: tlx, y2: tly, type: "spine.left"}
    right = %Line{x1: brx, y1: bry, x2: trx, y2: yrt, type: "spine.right"}
    top = %Line{x1: tlx, y1: tly, x2: trx, y2: yrt, type: "spine.top"}
    bottom = %Line{x1: blx, y1: bly, x2: brx, y2: bry, type: "spine.bottom"}
    element = [left, right, top, bottom]
    axes = %{axes | element: element}
    %Figure{figure | axes: axes}
  end

  def draw_spines(_figure) do
    raise ArgumentError, message: "Figure does't contain enough data to proceed"
  end

#TODO: Sort out how the user gets the control on font of the all texts
  def entitle(%Figure{axes: %{coords: %Coords{title: {ttx, tty}},title: %{text: text, height: height}, size: %{width: width}, element: elements} = axes, rc_params: rc_params} = figure) do
    title_font = rc_params|>RcParams.get_rc(:get_title_font)|>Map.from_struct()
   title = %Label{type: "figure.title", x: ttx, y: tty, text: text, height: height, width: width}|> merge_structs(title_font)
   %Figure{figure | axes: %{axes | element: elements ++ [title]}}
  end
  def entitle(%Figure{axes: %{show_title: false}} = figure), do: figure

  def entitle(_figure) do
    raise ArgumentError, message: "Figure does't contain enough data to proceed"
  end

  defp calculate_corners(
         {%Figure{axes: %{coords: coords} = axes, figsize: {f_width, f_height}, margin: margin} =
            figure, {width, height}}
       ) do
    by = f_height - height
    ty = f_height - f_height * margin
    lx = f_width - width
    rx = f_width - f_width * margin

    {%Figure{
       figure
       | axes: %{
           axes
           | coords: %{
               coords
               | bottom_left: {lx * @dpi, by * @dpi},
                 top_left: {lx * @dpi, ty * @dpi},
                 bottom_right: {rx * @dpi, by * @dpi},
                 top_right: {rx * @dpi, ty * @dpi}
             }
         }
     }, {width, height}}
  end

  defp peel_margin(
         %Figure{figsize: {width, height}, axes: %{coords: coords} = axes, margin: margin} =
           figure
       ) do
    label_coords = {width * margin, height - height * margin}

    {%Figure{
       figure
       | axes: %{
           axes
           | coords: %{
               coords
               | title: {width * margin, height * margin},
                 y_label: label_coords,
                 x_label: label_coords
             }
         }
     }, {width - width * margin, height - height * margin}}
  end

  # defp peel_margin({width, height, corners}, margin, {f_width, f_height}) do
  #   {{width - f_width * margin, height - f_height * margin}, corners}
  # end
  defp peel_margin(
         {%Figure{figsize: {f_width, f_height}, margin: margin} = figure, {width, height}}
       ) do
    {figure, {width - f_width * margin, height - f_height * margin}}
  end

  defp peel_label_offsets(
         {%Figure{
            axes: %{coords: %Coords{x_label: {xlx, xly}, y_label: {ylx, yly}} = coords} = axes,
            rc_params: rc_params
          } = figure, {width, height}}
       ) do
    x_label_font_size = RcParams.get_rc(rc_params, :get_x_label_font_size)
    y_label_font_size = RcParams.get_rc(rc_params, :get_y_label_font_size)

    x_label_offset = x_label_font_size * @pt_to_inch
    y_label_offset = y_label_font_size * @pt_to_inch

    {%Figure{
       figure
       | axes: %{
           axes
           | coords: %{
               coords
               | x_ticks: {xlx + y_label_offset, xly - x_label_offset},
                 y_ticks: {ylx + y_label_offset, yly - x_label_offset}
             }
         }
     }, {width - x_label_offset, height - y_label_offset}}
  end

  defp peel_title_offsets(
         {%Figure{
            rc_params: rc_params,
            axes: %{title: title} = axes
          } = figure, {width, height}}
       ) do
    title_font_size = RcParams.get_rc(rc_params, :get_title_font_size)

    title_offset = title_font_size * @pt_to_inch

    {%Figure{figure | axes: %{axes | title: %{title | height: title_offset * @dpi}}}, {width, height - title_offset}}
  end

  defp peel_tick_offsets(
         {%Figure{
            rc_params: rc_params,
            axes: %{tick: %{y: y_ticks}, coords: %Coords{x_ticks: {xtx, _}} = coords} = axes,
            margin: margin,
            figsize: {_width, figheight}
          } = figure, {width, height}}
       ) do
    tick_size = y_ticks |> Enum.max_by(fn tick -> tick_length(tick) end) |> tick_length()
    y_tick_font_size = RcParams.get_rc(rc_params, :get_y_tick_font_size)
    x_tick_font_size = RcParams.get_rc(rc_params, :get_x_tick_font_size)
    y_tick_offset = y_tick_font_size * @pt_to_inch * tick_size
    x_tick_offset = x_tick_font_size * @pt_to_inch

    {%Figure{
       figure
       | axes: %{
           axes
           | coords: %Coords{coords | title: {(xtx + x_tick_offset) * @dpi, figheight * margin * @dpi}}
         }
     }, {width - y_tick_offset, height - x_tick_offset}}
  end

  defp tick_length(tick) when is_integer(tick) do
    tick |> Integer.to_string() |> String.length()
  end

  defp tick_length(tick) when is_binary(tick) do
    String.length(tick)
  end

  defp tick_length(tick) when is_float(tick) do
    tick |> Float.to_string() |> String.length()
  end

  defp merge_structs(%module{} = st, params) do
    params = st|>Map.from_struct()|> Map.merge(params)
    struct(module, params)
  end
end
