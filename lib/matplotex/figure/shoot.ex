defmodule Matplotex.Figure.Shoot do

  defstruct [:header, :chart, :footer]
  use Agent
  def start_link(canvas) do
    Agent.start_link(fn -> %__MODULE__{header: canvas, chart: canvas, footer: footer()} end, name: __MODULE__)
  end

  def chart() do
    Agent.get(__MODULE__, & &1.chart <> &1.footer)
  end
  def stitch({:ok, elem}) do
    Agent.update(__MODULE__, fn %__MODULE__{chart: chart} = state -> %__MODULE__{state | chart: chart <> elem} end)
  end

  def footer() do
    ~s(</g>
      </svg>)
  end
end
