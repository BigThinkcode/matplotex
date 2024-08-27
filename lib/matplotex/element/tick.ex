defmodule Matplotex.Element.Tick do
  alias Matplotex.Element.Line
  alias Matplotex.Element.Label

  @type t() :: %__MODULE__{
          label: Label.t(),
          tick_line: Line.t()
        }
  defstruct [:label, :tick_line]
end
