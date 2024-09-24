defmodule Matplotex.Figure do
  @row_column_default 1
  @margin_default 0.1
  @figsize {10,6}
  defstruct [:id, :axes, :element,valid?: true, errors: [], figsize: @figsize, rows: @row_column_default, columns: @row_column_default, margin: @margin_default]
  @type t() :: %__MODULE__{
    id: String.t(),
    axes: any(),
    element: any(),
    valid?: boolean(),
    errors: [String.t()],
    figsize: {float(), float()},
    rows: integer(),
    columns: integer(),
    margin: float()
  }
  def new(opts) do
    struct(__MODULE__, opts)
  end
  def add_label(%__MODULE__{axes: %module{} = axes} = figure, label), do: %{figure | axes: module.add_label(axes, label) }
  def add_title(%__MODULE__{axes: %module{} = axes} = figure, title), do: %{figure | axes: module.add_title(axes, title)}
  def add_ticks(%__MODULE__{axes: %module{} = axes} = figure, ticks), do: %{figure | axes: module.add_ticks(axes, ticks)}
  def set_limit(%__MODULE__{axes: %module{} = axes} = figure, limit), do: %{figure | axes: module.set_limit(axes, limit)}
  def add_legend(%__MODULE__{axes: %module{} = axes} = figure, params), do: %{figure | axes: module.add_legend(axes, params)}
end
