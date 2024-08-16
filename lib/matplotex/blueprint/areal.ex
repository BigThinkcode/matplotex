defmodule Matplotex.Blueprint.Areal do
  alias Matplotex.Blueprint.Areal.Chart

  @callback new(params :: map()) :: Chart.t()
  @callback set_content(chartset :: Chart.t()) :: Chart.t()
  @callback add_axis_lines(chartset :: Chart.t()) :: Chart.t()
  @callback add_grid_lines(chartset :: Chart.t()) :: Chart.t()
  @callback add_components(chartset :: Chart.t()) :: Chart.t()
  @callback add_labels(chartset :: Chart.t()) :: Chart.t()
  @callback add_ticks(chartset :: Chart.t()) :: Chart.t()

  defmacro __using__(_) do
    quote do
      @behaviour Matplotex.Blueprint.Areal
      import Matplotex.Blueprint.Areal.Content
    end
  end
end
