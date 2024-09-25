defmodule Matplotex.Figure.LinePlot.Materialyzer do
  alias Matplotex.Figure.LinePlot
  alias Matplotex.Figure


  defp maybe_set_size(%Figure{axes: %{size: %{width: _, height: _}}}= figure) do
  figure
  end
  defp maybe_set_size(%Figure{axes: %{} = axes, figsize: {width, height}, margin: margin} = figure) do
  #calculate the width and height and by reducing margin and place for labels

figure
  end
end
