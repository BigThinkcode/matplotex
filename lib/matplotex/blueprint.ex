defmodule Matplotex.Blueprint do
  @callback new(graph :: module(),params :: map()) :: any()
  @callback set_content(graphset :: any()) :: any()
  @callback add_elements(graphset :: any()) :: any()
  @callback generate_svg(graphset :: any()) :: any()

  defmacro __using__(_) do
    quote do
      import Matplotex.Utils.Algebra

      import Matplotex.Utils.Helpers
      import Matplotex.Validation.Helpers
      alias Matplotex.Element.Line
      alias Matplotex.Element.Label
      alias Matplotex.Element.Tick
      @behaviour Matplotex.Blueprint
    end
  end
end
