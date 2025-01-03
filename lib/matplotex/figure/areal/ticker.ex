defmodule Matplotex.Figure.Areal.Ticker do
  @tick_in_plot 5
  def generate_ticks({min, max}) do
    step = (max - min) / @tick_in_plot
    produce_ticks(min, max, step, [format_number(min)])
  end

  def generate_ticks({lower_limit, upper_limit} = lim, number_of_ticks) do
    {lower_limit |> Nx.linspace(upper_limit, n: number_of_ticks) |> Nx.to_list(), lim}
  end

  defp produce_ticks(value, max, _step, ticks) when value >= max do
    Enum.reverse(ticks)
  end

  defp produce_ticks(value, max, step, ticks) do
    value = value + step
    value = format_number(value)
    produce_ticks(value, max, step, [value | ticks])
  end

  defp format_number(number) when is_integer(number), do: number

  defp format_number(number) when is_float(number) do
    Float.round(number, 2)
  end
end
