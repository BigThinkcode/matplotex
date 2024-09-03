defmodule Matplotex.BarChart do
  @moduledoc """
  Module wraps the functions to generate a barchart by input in a format of
   %{
          dataset: dataset1_d(),
          x_labels: list(),
          color_palette: String.t() | list(),
          width: number(),
          x_margin: number(),
          y_margin: number(),
          height: number(),
          y_scale: number(),
          y_label_sufix: String.t(),
          x_label_offset: number(),
          y_label_offset: number()
        }
  TODO: Barchart for multiple data for a catogory
  TODO: Control for show grid line on x y axis
  TODO: Control for show axis line
  TODO: Set title
  TODO: Accept id for the svg element from params
  TODO: Apply some validation before generating svg

  TODO: Horizontal Barchart
  TODO: Compatibility with phoenix LiveView
  TODO: Tooltip css

  """
import Matplotex.Blueprint.Frame

alias Matplotex.BarChart.Plot

  @type params() :: %{
    dataset: dataset1_d(),
    x_labels: list(),
    color_palette: String.t() | list(),
    width: number(),
    x_margin: number(),
    y_margin: number(),
    height: number(),
    y_scale: number(),
    y_label_sufix: String.t(),
    x_label_offset: number(),
    y_label_offset: number()
  }
@type t() :: frame_struct()

frame()



  def create(params) do
    __MODULE__
    |> Plot.new(params)
    |> Plot.set_content()
    |> Plot.add_elements()
    |> Plot.generate_svg()
  end
  end
