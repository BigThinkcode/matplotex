defmodule Matplotex.Blueprint do
  @callback new(params :: map()) :: any()
  # @callback validate_params(params :: map()) :: any()
  @callback set_content(graphset :: any()) :: any()
  @callback add_elements(graphset :: any()) :: any()
  # @callback generate_svg(graphset :: any()) :: any()

  defmacro __using__(_) do
    quote do
      import Matplotex.Utils.Algebra
      import Matplotex.Blueprint.Frame
      alias Matplotex.Element.Line
      alias Matplotex.Element.Label
      @behaviour Matplotex.Blueprint
    end
  end
end
