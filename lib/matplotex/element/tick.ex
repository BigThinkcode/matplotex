defmodule Matplotex.Element.Tick do
  alias Matplotex.Element
  alias Matplotex.Element.Line
  alias Matplotex.Element.Label
  use Element

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

  @impl Element
  def flipy(%__MODULE__{label: label, tick_line: tick_line} = tick, height) do
    %__MODULE__{
      tick
      | label: Label.flipy(label, height),
        tick_line: Line.flipy(tick_line, height)
    }
  end
end
