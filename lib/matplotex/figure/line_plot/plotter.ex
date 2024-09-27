defmodule Matplotex.LinePlot.Plotter do
  alias Matplotex.InputError
  # * Create a figure
  # * Create Axes on that figure

  def new(module, x, y) do
    module
    |> struct(%{data: {x, y}})
    |> fix_default_tick_and_limit()
  end

  # TODO: Wrote logic for string values also
  defp fix_default_tick_and_limit(%{data: {x, y}} = axes) when is_list(x) and is_list(y) do
    lenx = length(x)
    leny = length(y)

    {x_min, x_max, x_scale} = x_lim = Enum.min_max(x) |> make_min_max(lenx)
    {y_min, y_max, y_scale} = y_lim = Enum.min_max(y) |> make_min_max(leny)

    x_ticks = x_min..x_max |> Enum.to_list() |> Enum.into([], fn x -> x * x_scale end)
    y_ticks = y_min..y_max |> Enum.to_list() |> Enum.into([], fn y -> y * y_scale end)
    %{axes | data: {x, y}, limit: %{x: x_lim, y: y_lim}, tick: %{x: x_ticks, y: y_ticks}}
  end

  defp fix_default_tick_and_limit(_) do
    raise InputError, message: "Invalid x and y values for plot, x and y should be in list"
  end

  defp make_min_max({min, max}, length), do: {min - 1, max + 1, (max - min + 2) / (length + 1)}
end
