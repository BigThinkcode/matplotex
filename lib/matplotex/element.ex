defmodule Matplotex.Element do
  @callback assemble(element :: struct()) :: String.t()
  def assemble(%module{} = element), do: module.assemble(element)
end
