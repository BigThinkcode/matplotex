defmodule Matplotex do
  @moduledoc """
  Matplotex — a comprehensive charting library for Elixir.

  All coordinate math runs through Nx tensor operations. Every chart type
  implements the same three-callback behaviour; the compile pipeline and
  SVG renderer are chart-type agnostic.

  ## Quick start

      alias Matplotex.{Chart, Axis, Dataset}
      alias Matplotex.Render.SVG

      Chart.new(:line)
      |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom, label: "Month"})
      |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left,   label: "Revenue"})
      |> Chart.add_data(Enum.zip(1..12, [3,5,4,8,7,9,6,10,8,11,9,12]), name: "2024")
      |> Chart.set_title("Monthly Revenue")
      |> Chart.compile()
      |> SVG.to_svg()
  """

  defdelegate compile(chart), to: Matplotex.Chart
  defdelegate to_svg(chart), to: Matplotex.Render.SVG
end
