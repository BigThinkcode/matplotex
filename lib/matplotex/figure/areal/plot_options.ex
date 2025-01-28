defmodule Matplotex.Figure.Areal.PlotOptions do
  @moduledoc false
  alias Matplotex.Figure
  alias Matplotex.Figure.TwoD
  alias Matplotex.Figure.RcParams

  @immutable_keys [
    :axes,
    :rc_params,
    :elements,
    :region_x,
    :region_y,
    :region_title,
    :region_content,
    :region_legend,
    :region_color_bar
  ]

  @spec set_options_in_figure(Figure.t(), keyword()) :: Figure.t()
  def set_options_in_figure(%Figure{} = figure, opts) do
    opts = sanitize(opts)

    figure
    |> cast_figure(opts)
    |> cast_axes(opts)
    |> cast_rc_params(opts)
  end

  defp cast_figure(figure, opts) do
    struct(figure, opts)
  end

  defp cast_axes(%Figure{axes: axes} = figure, opts) do
    opts = Keyword.delete(opts, :label)

    %Figure{
      figure
      | axes: axes |> struct(opts) |> cast_two_d_structs(opts)
    }
  end

  defp cast_two_d_structs(%{label: label, tick: tick, limit: limit} = axes, opts)
       when is_map(opts) do
    %{
      axes
      | label: TwoD.update(label, opts, :label),
        tick: TwoD.update(tick, opts, :tick),
        limit: TwoD.update(limit, opts, :limit)
    }
  end

  defp cast_two_d_structs(axes, opts), do: cast_two_d_structs(axes, Enum.into(opts, %{}))

  defp cast_rc_params(%Figure{rc_params: rc_params} = figure, opts) do
    %Figure{figure | rc_params: rc_params |> RcParams.update_with_font(opts) |> struct(opts)}
  end

  defp sanitize(opts) do
    Keyword.drop(opts, @immutable_keys)
  end
end
