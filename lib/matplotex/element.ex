defmodule Matplotex.Element do
  @moduledoc false
  @callback assemble(element :: struct()) :: String.t()
  def assemble(%module{} = element), do: module.assemble(element)

  def to_pixel({x, y}) do
    "#{to_pixel(x)},#{to_pixel(y)}"
  end

  def to_pixel(inch) when is_number(inch), do: inch * 96
  def to_pixel(_), do: 0

  defmacro __using__(_opts) do
    quote do
      @behaviour Matplotex.Element
      import Matplotex.Element, only: [to_pixel: 1]

      defimpl String.Chars, for: __MODULE__ do
        def to_string(%module{} = element) do
        module.assemble(element)
        end
      end
    end
  end
end
