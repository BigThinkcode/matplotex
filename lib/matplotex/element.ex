defmodule Matplotex.Element do
  @callback assemble(element :: struct()) :: String.t()
  @callback flipy(element :: struct(), height :: number()) :: struct()
  def assemble(%module{} = element), do: module.assemble(element)

  def to_pixel(inch) when is_number(inch), do: inch * 96
  def to_pixel(_), do: 0

  defmacro __using__(_opts) do
    quote do
      @behaviour Matplotex.Element
      import Matplotex.Element, only: [to_pixel: 1]

    end
  end
end
