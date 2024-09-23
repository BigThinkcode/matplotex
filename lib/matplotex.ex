defmodule Matplotex do
  @moduledoc """
  Documentation for `Matplotex`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Matplotex.hello()
      :world

  """
  def barchart(params) do
    Matplotex.BarChart.create(params)
  end

  def pie_chart(params) do
    Matplotex.PieChart.create(params)
  end
  def plot(x, y) do
    Matplotex.LinePlot.create(x,y)
  end
end
