defmodule Matplotex.LinePlot do
  import Matplotex.Blueprint.Frame

  @type params():: %{
    id: String.t(),
    width: number(),
    height: number(),
    dataset: list(),
    x_labels: list(),
    show_x_axis: boolean(),
    show_y_axis: boolean(),
    show_v_grid: boolean(),
    show_h_grid: boolean(),
    x_margin: number(),
    y_margin: number(),
    line_width: number(),
    color_palette: list(),
    title: title(),
    x_label_offset: number(),
    y_label_offset: number(),
    y_scale: number(),
    x_scale: number(),

  }


  frame()
  @type t() :: frame_struct()
  def create(params) do

  end
end
