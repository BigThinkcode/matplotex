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
  use Matplotex.Blueprint
  @type word() :: String.t()
  @type params() :: %{
    id: word(),
    title: word(),
    data: list(),
    labels: list(),
    color_palette: list(),
    stroke_width: number(),
    width: number(),
    height: number(),
    margin: number(),
    legends: boolean(),
    label: boolean()

  }
  frame()
  @type t() :: frame_struct()
  @impl true
  def new(params) do
    #Fields are dataset, title, size, margin, valid, element, type
    # type: pie chart, dataset from params combination of  data and labels,

    struct(__MODULE__, params)
  end
  @impl true
  def set_content(graphset) do
    #params will serve color_palette, legends, label, stroke_width,
    graphset
  end
  @impl true
  def add_elements(graphset) do
    #adding elements means adding slices and legends and labels
    graphset
  end
  @impl true
  def generate_svg(_graphset) do
    #Before generating svg it structs with x1 y1, x2, y2, radius, of the slice
    ""
  end

  defp generate_slices(content) do
    # cx and cy are the center
    # will calculate the angle by percentage and take the xn and yn by using R.cos(angle*pie/180) and R.sign(angle*pie/180)

  end
end
