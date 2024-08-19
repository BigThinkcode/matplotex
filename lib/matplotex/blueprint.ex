defmodule Matplotex.Blueprint do
  alias Matplotex.Blueprint.Chart

  @callback new(params :: map()) :: any()
  @callback validate_params(params :: map()) :: any()
  @callback set_content(graphset :: any()) :: any()
  @callback add_elements(graphset :: any()) :: any()
  @callback generate_svg(graphset :: any()) :: any()

  defmacro __using__(_) do
    quote do
      import Matplotex.Utils.Algebra
      import Matplotex.Blueprint.Frame
      @behaviour Matplotex.Blueprint
    end
  end
end
