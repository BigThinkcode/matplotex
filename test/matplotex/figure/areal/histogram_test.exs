defmodule Matplotex.Figure.Areal.HistogramTest do
  use Matplotex.PlotCase
  alias Matplotex.Figure.Areal.Histogram

  setup do
    values = Nx.Random.key(12) |> Nx.Random.normal(0, 1, shape: {1000}) |> elem(0) |> Nx.to_list()
    bins = 30

    figure =
      Matplotex.hist(values, bins, x_label: "Value", y_label: "Frequency", title: "Histogram")

    {:ok, %{figure: figure, bins: bins}}
  end

  describe "materialyze/1" do
    test "materialyze with elements", %{figure: figure, bins: bins} do
      assert figure = Histogram.materialize(figure)
      elements = figure.axes.element
      assert title = elements |> Enum.filter(fn elem -> elem.type == "figure.title" end) |> hd
      assert title.text == "Histogram"
      assert x_label = elements |> Enum.filter(fn elem -> elem.type == "figure.x_label" end) |> hd
      assert x_label.text == "Value"
      assert y_label = elements |> Enum.filter(fn elem -> elem.type == "figure.y_label" end) |> hd
      assert y_label.text == "Frequency"
      x_ticks = elements |> Enum.filter(fn elem -> elem.type == "figure.x_tick" end)
      y_ticks = elements |> Enum.filter(fn elem -> elem.type == "figure.y_tick" end)
      histogram_elements = elements|>Enum.filter(fn elem -> elem.type == "figure.histogram" end)
      assert length(histogram_elements) == bins
    end
  end
end
