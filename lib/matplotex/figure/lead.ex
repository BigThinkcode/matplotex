defmodule Matplotex.Figure.Lead do
  alias Matplotex.Element.Line
  alias Matplotex.Figure.RcParams
  alias Matplotex.Figure
  @pt_to_inch 1 / 72
  @dpi 96

  def set_spines(
        %Figure{
          axes: %{tick: ticks} = axes,
          figsize: figsize,
          margin: margin,
          rc_params: rc_params
        } = figure
      ) do
    {{width, height}, {bottom_left, top_left, bottom_right, top_right}} =
      figsize
      |> peel_margin(margin)
      |> peel_label_offsets(rc_params)
      |> peel_tick_offsets(rc_params, ticks)
      |> calculate_corners(figsize, margin)
      |> peel_margin(margin, figsize)

    axes = %{
      axes
      | size: %{width: width * @dpi, height: height * @dpi},
        bottom_left: bottom_left,
        top_left: top_left,
        bottom_right: bottom_right,
        top_right: top_right
    }

    %Figure{figure | axes: axes}
  end

  def set_spines(_) do
    raise ArgumentError, message: "Figure does't contain enough data to proceed"
  end

  def draw_spines(
        %Figure{
          axes:
            %{
              bottom_left: {blx, bly},
              bottom_right: {brx, bry},
              top_left: {tlx, tly},
              top_right: {trx, yrt}
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

  defp calculate_corners({width, height}, {f_width, f_height}, margin) do
    by = f_height - height
    ty = f_height - f_height * margin
    lx = f_width - width
    rx = f_width - f_width * margin

    {width, height,
     {{lx * @dpi, by * @dpi}, {lx * @dpi, ty * @dpi}, {rx * @dpi, by * @dpi},
      {rx * @dpi, ty * @dpi}}}
  end

  defp peel_margin({width, height}, margin) do
    {width - width * margin, height - height * margin}
  end

  defp peel_margin({width, height, corners}, margin, {f_width, f_height}) do
    {{width - f_width * margin, height - f_height * margin}, corners}
  end

  defp peel_label_offsets({width, height}, rc_params) do
    x_label_font_size = RcParams.get_rc(rc_params, :get_x_label_font_size)
    y_label_font_size = RcParams.get_rc(rc_params, :get_y_label_font_size)

    x_label_offset = x_label_font_size * @pt_to_inch
    y_label_offset = y_label_font_size * @pt_to_inch
    {width - x_label_offset, height - y_label_offset}
  end

  defp peel_tick_offsets({width, height}, rc_params, %{y: y_ticks}) do
    tick_size = y_ticks |> Enum.max_by(fn tick -> tick_length(tick) end) |> tick_length()
    y_tick_font_size = RcParams.get_rc(rc_params, :get_y_tick_font_size)
    x_tick_font_size = RcParams.get_rc(rc_params, :get_x_tick_font_size)
    y_tick_offset = y_tick_font_size * @pt_to_inch * tick_size
    x_tick_offset = x_tick_font_size * @pt_to_inch
    {width - y_tick_offset, height - x_tick_offset}
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
end
