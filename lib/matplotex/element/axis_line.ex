defmodule Matplotex.Element.AxisLine do
  alias Matplotex.Element.Line

  def genarate_axis_lines(chartset) do
    xaxis = generate_axis(chartset, :x)
    yaxis = generate_axis(chartset, :y)

    [xaxis, yaxis]
  end

  defp generate_axis(
         %{
           content: %{x: content_x, y: content_y},
           size: %{width: width},
           show_x_axis: true
         },
         :x
       ) do


    %Line{
      type: "axis.xaxis",
      x1: content_x,
      y1: content_y,
      x2: width,
      y2: content_y
    }
  end

  defp generate_axis(
         %{
           content: %{x: content_x, y: content_y},
           show_y_axis: true
         },
         :y
       ) do
    %Line{
      type: "axis.yaxis",
      x1: content_x,
      y1: content_y,
      x2: content_x,
      y2: 0
    }
  end

  defp generate_axis(_, _), do: nil
end
