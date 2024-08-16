defmodule Matplotex.Blueprint do
  alias Matplotex.Blueprint.Chart

  @callback new(params :: map()) :: Chart.t()
  @callback validate_params(params :: map()) :: Chart.t()
  @callback set_content(chartset :: Chart.t()) :: Chart.t()
  @callback add_elements(chartset :: Chart.t()) :: Chart.t()

  defmacro __using__(_) do
    quote do
      @behaviour Matplotex.Blueprint
      import Matplotex.Blueprint.Content
    end
  end
end
