defmodule Matplotex.Figure.Cast do
  alias Matplotex.Figure.RcParams
  alias Matplotex.Element.Label
  alias Matplotex.Element.Line
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure
  @dpi 96

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
    raise ArgumentError, message: "Figure does't contain enough data to proceed"
  end

  def cast_label(%Figure{axes: %{label: labels, coords: coords}, rc_params: rc_params}) do
     Enum.map(labels, fn {axis, label} ->
      {x, y} = label_coords = Map.get(coords, :"#{axis}_label")
         ticks_coords = Map.get(coords, :"#{axis}_ticks")
        height =  calculate_distance(label_coords,ticks_coords)
        width = calculate_width(coords, axis)
        label_font = rc_params|>RcParams.get_rc(:"get_#{axis}_label_font")|>Map.from_struct()
      %Label{type: "figure.#{axis}_label", x: to_pixel(x), y: to_pixel(y), text: label, height: to_pixel(height), width: to_pixel(width)}|>merge_structs(label_font)
     end )
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
