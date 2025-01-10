defmodule Matplotex.Figure.Numer do
@moduledoc false
  def round_to_best(value) when value > 10 do
    factor = value |> :math.log10() |> floor()

    base = 10 |> :math.pow(factor) |> round()
    value |> round() |> div(base) |> Kernel.*(base)
  end

  # TODO: get best strategy for ticks less than 1
  def round_to_best(value) do
    value
  end
end
