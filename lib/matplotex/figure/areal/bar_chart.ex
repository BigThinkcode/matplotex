defmodule Matplotex.Figure.Areal.BarChart do
  alias Matplotex.Figure.RcParams
  alias Matplotex.Element.Line
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure
  alias Nx

  @tensor_data_type_bits 64

  use Matplotex.Figure.Areal

  def create(x, y) do
    %Figure{axes: struct(__MODULE__, %{data: {x, y}})}
  end
end
