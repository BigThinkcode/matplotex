defmodule Matplotex.LinePlot do
  alias Matplotex.Figure.TwoD
  alias Matplotex.Figure.Dimension
  alias Matplotex.Figure.Cast
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure.Lead
  alias Matplotex.Figure.Text
  alias Matplotex.Figure.Font
  alias Matplotex.Figure
  alias Matplotex.Figure.Legend
  import Matplotex.Blueprint.Frame


  frame(legend: %Legend{}, coords: %Coords{}, dimension: %Dimension{}, tick: %TwoD{}, limit: %TwoD{})
  @type t() :: frame_struct()
  def create(x, y) do
    %Figure{axes: struct(__MODULE__,%{data: {x, y}})}
  end

  def add_label(%__MODULE__{label: nil} = axes, {key, label}, opts) when is_binary(label) do
    label =
      Map.new()
      |> Map.put(key, create_text(label, opts))

    update_label(axes, label)
  end

  def add_label(%__MODULE__{label: ax_label} = axes, {key, label}, opts) when is_binary(label) do
    label = Map.put(ax_label, key, create_text(label, opts))
    update_label(axes, label)
  end

  def add_label(_axes, _label) do
    raise Matplotex.InputError, keys: [:label], message: "Invalid input"
  end

  def add_title(axes, title, opts) when is_binary(title) do
    title = create_text(title, opts)
    %{axes | title: title, show_title: true}
  end

  def add_title(_, _) do
    raise Matplotex.InputError, keys: [:title], message: "Invalid Input"
  end

  def add_ticks(%__MODULE__{tick: nil} = axes, {key, ticks}) when is_list(ticks) do
    tick =
      Map.new()
      |> Map.put(key, ticks)

    update_tick(axes, tick)
  end

  def add_ticks(%__MODULE__{tick: tick} = axes, {key, ticks}) when is_list(ticks) do
    tick = Map.put(tick, key, ticks)
    update_tick(axes, tick)
  end

  def add_ticks(_, _) do
    raise Matplotex.InputError, keys: [:tick], message: "Invalid Input"
  end

  def set_limit(%__MODULE__{limit: nil} = axes, {key, {_, _} = lim}) do
    limit =
      Map.new()
      |> Map.put(key, lim)

    update_limit(axes, limit)
  end

  def set_limit(%__MODULE__{limit: limit} = axes, {key, {_, _} = lim}) do
    limit = Map.put(limit, key, lim)
    update_limit(axes, limit)
  end

  def set_limit(_, _) do
    raise Matplotex.InputError, keys: [:limit], message: "Invalid Input"
  end

  def add_legend(%__MODULE__{legend: nil} = axes, params) do
    legend = struct(Legend, params)
    %{axes | legend: legend}
  end

  def add_legend(%__MODULE__{legend: legend} = axes, params) do
    legend = Map.merge(legend, params)
    %{axes | legend: legend}
  end

  def generate_xticks(%__MODULE__{data: {x, _y}, tick: tick, limit: limit} = axes) do
    {xticks, xlim} =
      if number_based?(x) do
      generate_ticks(x)
      else
        generate_ticks_with_pos(x)
    end
    tick = Map.put(tick, :x, xticks)
    limit = Map.put(limit, :x, xlim)
    %__MODULE__{axes | tick: tick, limit: limit}
  end
  def generate_yticks(%__MODULE__{data: {_x, y}, tick: tick, limit: limit} = axes) do
    {xticks, ylim} =
      if number_based?(y) do
      generate_ticks(y)
      else
        generate_ticks_with_pos(y)
    end
    tick = Map.put(tick, :y, xticks)
    limit = Map.put(limit, :y, ylim)
    %__MODULE__{axes | tick: tick, limit: limit}
  end
  def materialize(figure) do
    figure
    |> Lead.set_spines()
    |> Cast.cast_spines()
    |> Cast.cast_label()
    |> Cast.cast_title()
    |> Cast.cast_xticks()
    |> Cast.cast_yticks()
    |> Cast.cast_hgrids()
    |> Cast.cast_vgrids()

    # generate svg equalent elements for the plot
    # generate svg elements for legend
    # generate svg elements for labels and axis
    # generate svg elements for data points
    # generate svg elements for grid lines
    # generate svg elements for title
    # generate svg elements for x and y labels
    # generate svg elements for x and y ticks
    # generate svg elements for x and y limits
    # generate svg elements for legend
    # generate svg elements for plot background
    # generate svg elements for plot border
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

  defp create_text(label, opts) do
    {font_params, _opts} = Keyword.split(opts, Font.font_keys())
    font_params = Enum.into(font_params, %{})
    font = struct(Font, font_params)
    Text.new(label, font)
  end

  defp number_based?(data) do
    Enum.all?(data, &is_number/1)
  end

  defp generate_ticks(data) do
    step = Enum.max(data) / length(data)
  {min, max} = Enum.min_max(data)
  {min, max} = lim = {round(min-step), round(max + step)}
  {min..max |> Enum.into(fn d -> d * step end), lim}
  end

  defp generate_ticks_with_pos(data) do
    ticks = Enum.with_index(data)
    {ticks, min_max(ticks)}
  end
  defp min_max([{_pos, _label} | _] = ticks) do
    ticks
    |> Enum.min_max_by(fn {pos, _label} -> pos end)
    |> then(fn {{pos_min, _label_min}, {pos_max, _label_max}} -> {pos_min, pos_max} end)
  end

  defp min_max(ticks) do
    Enum.min_max(ticks)
  end


end
