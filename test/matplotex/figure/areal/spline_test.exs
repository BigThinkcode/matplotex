defmodule Matplotex.Figure.Areal.SplineTest do
  use Matplotex.PlotCase
  alias Matplotex.Figure
  alias Matplotex.Figure.Areal.Spline
  setup do
        x_nx = Nx.linspace(0, 10, n: 100)
        x = Nx.to_list(x_nx)
        y = x_nx |> Nx.sin() |> Nx.to_list()

    figure =  Matplotex.spline(x, y, x_label: "X", y_label: "Y")
     {:ok, %{figure: figure}}
    end


    test "adds a spline element in a figure",%{figure: figure} do
      assert %Figure{axes: %Spline{element: elements}} =Spline.materialize(figure)
      assert Enum.any?(elements, &(&1.type=="figure.spline"))
    end
end
