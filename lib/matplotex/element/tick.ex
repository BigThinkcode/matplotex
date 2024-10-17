defmodule Matplotex.Element.Tick do
  alias Matplotex.Element
  alias Matplotex.Element.Line
  alias Matplotex.Element.Label
  @behaviour Element

  @type t() :: %__MODULE__{
          label: Label.t(),
          tick_line: Line.t()
        }
  defstruct [:type, :label, :tick_line]

  @impl Element
  def assemble(tick) do
    ~s(
     #{Element.assemble(tick.tick_line)}
     #{Element.assemble(tick.label)}
    )
  end
end
