defmodule Matplotex.LinePlot do
  alias Matplotex.Figure

  alias Matplotex.LinePlot.Plotter
  alias Matplotex.Figure.Legend
  import Matplotex.Blueprint.Frame

  @type params() :: %{
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
          x_scale: number()
        }

  frame()
  @type t() :: frame_struct()
  def create(x,y) do
    %Figure{axes: Plotter.new(__MODULE__, x, y)}
  end
  def add_label(%__MODULE__{label: nil} = axes,{key,label}) when is_binary(label) do
  label =  Map.new()
           |>Map.put(key, label)
   update_label(axes, label)
  end
  def add_label(%__MODULE__{label: label} = axes, {key,label}) when is_binary(label) do
    label = Map.put(label, key, label)
    update_label(axes, label)
  end
  def add_label(_axes, _label) do
   raise Matplotex.InputError, keys: [:label], message: "Invalid input"
  end
  def add_title(axes, title) when is_binary(title) do
    %{axes | title: title}
  end
  def add_title(_,_) do
    raise Matplotex.InputError, keys: [:title], message: "Invalid Input"
  end
  def add_tick(%__MODULE__{tick: nil} = axes, {key, ticks}) when is_list(ticks) do
    tick =  Map.new()
           |>Map.put(key, ticks)
    update_tick(axes, tick)
  end
  def add_tick(%__MODULE__{tick: tick} = axes, {key, ticks}) when is_list(ticks) do
    tick = Map.put(tick,key, ticks)
    update_tick(axes, tick)
  end

  def add_tick(_,_) do
    raise Matplotex.InputError, keys: [:tick], message: "Invalid Input"
  end


  def set_limit(%__MODULE__{limit: nil} = axes, {key, {_,_}= lim})  do
    limit =  Map.new()
           |>Map.put(key, lim)
    update_limit(axes, limit)
  end
  def set_limit(%__MODULE__{limit: limit} = axes, {key, {_,_} = lim}) do
    limit = Map.put(limit, key, lim)
    update_limit(axes, limit)
  end
  def set_limit(_,_) do
    raise Matplotex.InputError, keys: [:limit], message: "Invalid Input"
  end
  def add_legend(%__MODULE__{legend: nil} = axes, params ) do
    legend = struct(Legend, params)
    %{axes | legend: legend}
  end
  def add_legend(%__MODULE__{legend: legend} = axes, params ) do
    legend = Map.merge(legend, params)
    %{axes | legend: legend}
  end
  defp update_tick(axes, tick) do
    %{axes | tick: tick}
  end

  defp update_label(axes, label) do
    %{axes | label: label}
  end
  defp update_limit(axes, limit) do
    %{axes | limit: limit}
  end
end
