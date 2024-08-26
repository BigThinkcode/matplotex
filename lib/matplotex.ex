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
end
