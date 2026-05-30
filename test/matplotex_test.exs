defmodule MatplotexTest do
  use ExUnit.Case, async: true
  alias Matplotex.{Chart, Axis}

  test "compile/1 delegates to Chart.compile/1" do
    chart =
      Chart.new(:line)
      |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
      |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
      |> Chart.add_data(Enum.zip(1..3, [1, 2, 3]))

    compiled = Matplotex.compile(chart)
    assert MapSet.size(compiled.dirty) == 0
  end

  test "to_svg/1 delegates to SVG renderer" do
    chart =
      Chart.new(:line)
      |> Chart.put_axis(:x1, %Axis{dimension: :x, position: :bottom})
      |> Chart.put_axis(:y1, %Axis{dimension: :y, position: :left})
      |> Chart.add_data(Enum.zip(1..3, [1, 2, 3]))
      |> Matplotex.compile()

    assert is_binary(Matplotex.to_svg(chart))
  end
end
