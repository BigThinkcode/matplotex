defmodule Matplotex.LinePlot.Plotter do
  # * Create a figure
  # * Create Axes on that figure

  def new(module, x, y) do
    struct(module, %{data: {x, y}})
  end
end
