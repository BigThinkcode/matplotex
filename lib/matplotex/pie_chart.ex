defmodule Matplotex.PieChart do
  @moduledoc """
  Module wraps functions to create a PieChart
  <path d="M 421.51813336588265 240.05640787783966
  A 115 115 0 0 1 332.9904427005054 263.7351087416512
  L 350 150  Z"
  fill="gray"
  stroke="rgba(0,0,0,1)"
  stroke-width="0"
  ></path>
  """

  import Matplotex.Blueprint.Frame
  alias Matplotex.PieChart.Plot

  @type word() :: String.t()
  @type params() :: %{
          id: word(),
          title: word(),
          dataset: list(),
          labels: list(),

          color_palette: list(),
          stroke_width: number(),
          width: number(),
          height: number(),
          margin: number(),
          legends: boolean()
        }
  frame()
  @type t() :: frame_struct()
  def create(params) do
    __MODULE__
    |> Plot.new(params)
    |> Plot.set_content()
    |> Plot.add_elements()
    |> Plot.generate_svg()
  end
end
