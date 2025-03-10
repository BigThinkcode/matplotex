defmodule Matplotex.Figure.Areal.Heatmap do
  @moduledoc false

  alias Matplotex.Figure.Areal.Region
  alias Matplotex.Figure
  alias Matplotex.Figure.Areal
  alias Matplotex.Figure.TwoD
  use Areal
  frame(
    tick: %TwoD{},
    limit: %TwoD{},
    label: %TwoD{},
    region_x: %Region{},
    region_y: %Region{},
    region_title: %Region{},
    region_legend: %Region{},
    region_content: %Region{}
  )

  @impl Areal
  def create(%Figure{axes: %__MODULE__{dataset: dataset} = axes } = figure, data, opts) do
    {rows, columns} = data|> Nx.tensor()|>Nx.size()
    rows_idx = Nx.iota({rows, columns}, axis: 0)
    columns_idx = Nx.iota({})

  end
end
