defmodule Matplotex.Figure do
  @row_column_default 1
  @margin_default 0.1
  @figsize {10,6}
  defstruct [:id, :axes, :element, figsize: @figsize, rows: @row_column_default, columns: @row_column_default, margin: @margin_default]

  def new(opts) do
    struct(__MODULE__, opts)
  end
end
