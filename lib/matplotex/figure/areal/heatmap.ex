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
    data_tensor = data|> Nx.tensor()
    {rows, columns} = data_tensor|>Nx.size()
    row_indices = Nx.iota({rows, columns}, axis: 0)
    column_indices = Nx.iota({rows, columns }, axis: 1)

    row_flat = Nx.flatten(row_indices)
    col_flat = Nx.flatten(column_indices)
    values = Nx.flatten(data_tensor)
    dataset = Dataset.cast(%Dataset{x: row_flat, y: column_flat, colours: values}, opts) |>Dataset.update_cmap()
    datasets = data ++ [dataset]
    xydata = flatten_for_data(datasets)
    %Figure{figure | axes: %{axes | data: xydata, dataset: datasets}}
    |> PlotOptions.set_options_in_figure(opts)
  end

  def materialyze(figure), do: figure
end
