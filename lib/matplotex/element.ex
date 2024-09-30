defmodule Matplotex.Element do
  @callback assemble(element :: struct()) :: String.t()
end
