defmodule Matplotex.Figure.Areal.BarChart do
  alias Matplotex.Figure.RcParams
  alias Matplotex.Element.Line
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure
  alias Nx

  @tensor_data_type_bits 64

  alias Matplotex.Figure.Areal
  use Areal
  @impl Areal
  def create(x, y) do
    x = determine_numeric_value(x)
    y = determine_numeric_value(y)
    %Figure{axes: struct(__MODULE__, %{data: {x, y}})}
  end
  @impl Areal
  def materialize(figure) do
    __MODULE__.materialized(figure)
    |> materialize_bars()
  end
  defp materialize_bars(%Figure{axes: %{data: {x, y},limit: %{x: xlim, y: ylim},size: {width, height},coords: %Coords{bottom_left: {blx, bly}}, element: elements} = axes, rc_params: %RcParams{chart_padding: padding}} = figure) do

  end
end
