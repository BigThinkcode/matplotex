defmodule Matplotex.PlotCase do
  alias Matplotex.Figure.Lead
  use ExUnit.CaseTemplate

  using do
    quote do
      import Matplotex.PlotCase, only: [set_bar: 0]
    end
  end

  def set_figure() do
    figure = Matplotex.FrameHelpers.sample_figure() |> Lead.set_spines()
    {:ok, %{figure: figure}}
  end

  def set_bar() do
    {:ok, %{figure: Matplotex.FrameHelpers.bar() |> Lead.set_spines()}}
  end
end
