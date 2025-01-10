defmodule Matplotex.Figure.Areal.PlotOptions do
@moduledoc false
  alias Matplotex.Figure
  alias Matplotex.Figure.TwoD
  alias Matplotex.Figure.RcParams
  alias Matplotex.Figure.Font

  @type t :: %__MODULE__{
          figsize: {integer(), integer()},
          figrows: integer(),
          figcolumns: integer(),
          margin: float(),
          title: String.t() | nil,
          x_label: String.t() | nil,
          y_label: String.t() | nil,
          x_limit: :default | {float(), float()},
          y_limit: :default | {float(), float()},
          title_font_size: integer(),
          title_font_color: String.t(),
          x_label_font_size: integer(),
          y_label_font_size: integer(),
          x_label_font_color: String.t(),
          y_label_font_color: String.t(),
          show_x_axis: boolean(),
          show_y_axis: boolean(),
          x_scale: :default | float(),
          y_scale: :default | float(),
          show_x_ticks: boolean(),
          show_y_ticks: boolean(),
          show_x_ticks_label: boolean(),
          show_y_ticks_label: boolean(),
          x_tick_font_size: integer(),
          y_tick_font_size: integer(),
          x_tick_label_rotation: integer(),
          y_tick_label_rotation: integer(),
          x_tick_font_color: String.t(),
          y_tick_font_color: String.t(),
          show_v_grid: boolean(),
          show_h_grid: boolean(),
          legend_font_size: integer(),
          legend_font_color: String.t(),
          plot_line_style: String.t(),
          plot_line_width: float(),
          grid_linestyle: String.t(),
          grid_linewidth: float(),
          grid_color: String.t(),
          x_padding: float(),
          y_padding: float()
        }

  defstruct figsize: {10, 6},
            figrows: 1,
            figcolumns: 1,
            margin: 0.05,
            title: nil,
            x_label: nil,
            y_label: nil,
            x_limit: :default,
            y_limit: :default,
            title_font_size: 14,
            title_font_color: "black",
            x_label_font_size: 12,
            y_label_font_size: 12,
            x_label_font_color: "black",
            y_label_font_color: "black",
            show_x_axis: true,
            show_y_axis: true,
            x_scale: :default,
            y_scale: :default,
            show_x_ticks: true,
            show_y_ticks: true,
            show_x_ticks_label: true,
            show_y_ticks_label: true,
            x_tick_font_size: 10,
            y_tick_font_size: 10,
            x_tick_label_rotation: 0,
            y_tick_label_rotation: 0,
            x_tick_font_color: "black",
            y_tick_font_color: "black",
            show_v_grid: true,
            show_h_grid: true,
            legend_font_size: 9,
            legend_font_color: "black",
            plot_line_style: "_",
            plot_line_width: 1.0,
            grid_linestyle: "--",
            grid_linewidth: 1.0,
            grid_color: "#ddd",
            x_padding: 0.05,
            y_padding: 0.05

  @spec cast_options(map()) :: __MODULE__.t()
  def cast_options(opts), do: struct(__MODULE__, opts)

  @spec set_options_in_figure(Figure.t(), __MODULE__.t()) :: Figure.t()
  def set_options_in_figure(%Figure{} = figure, %__MODULE__{} = options) do
    figure
    |> set_options_in_figure_struct(options)
    |> set_options_in_axes_struct(options)
    |> set_options_in_rc_params_struct(options)
  end

  @spec set_options_in_figure(Figure.t(), keyword()) :: Figure.t()
  def set_options_in_figure(%Figure{} = figure, opts) do
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

  defp set_options_in_figure_struct(%Figure{} = figure, %__MODULE__{
         figsize: figsize,
         figrows: figrows,
         figcolumns: figcolumns,
         margin: margin
       }) do
    %Figure{figure | figsize: figsize, rows: figrows, columns: figcolumns, margin: margin}
  end

  defp set_options_in_axes_struct(
         %Figure{axes: axes} = figure,
         %__MODULE__{
           title: title,
           x_label: x_label,
           y_label: y_label,
           x_limit: x_limit,
           y_limit: y_limit
         }
       ) do
    %Figure{
      figure
      | axes: %{
          axes
          | title: title,
            label: %TwoD{x: x_label, y: y_label},
            limit: %TwoD{x: x_limit, y: y_limit}
        }
    }
  end

  defp set_options_in_rc_params_struct(
         %Figure{
           axes: axes,
           rc_params:
             %RcParams{
               title_font: title_font,
               x_label_font: x_label_font,
               y_label_font: y_label_font,
               x_tick_font: x_tick_font,
               y_tick_font: y_tick_font,
               legend_font: legend_font
             } = rc_params
         } = figure,
         %__MODULE__{
           title_font_size: title_font_size,
           title_font_color: title_font_color,
           x_label_font_size: x_label_font_size,
           y_label_font_size: y_label_font_size,
           x_label_font_color: x_label_font_color,
           y_label_font_color: y_label_font_color,
           show_x_axis: show_x_axis,
           show_y_axis: show_x_axis,
           x_scale: x_scale,
           y_scale: y_scale,
           show_x_ticks: show_x_ticks,
           show_y_ticks: show_y_ticks,
           show_x_ticks_label: _show_x_ticks_label,
           show_y_ticks_label: _show_y_ticks_label,
           x_tick_font_size: x_tick_font_size,
           y_tick_font_size: y_tick_font_size,
           x_tick_label_rotation: _x_tick_label_rotation,
           y_tick_label_rotation: _y_tick_label_rotation,
           x_tick_font_color: x_tick_font_color,
           y_tick_font_color: y_tick_font_color,
           show_v_grid: show_v_grid,
           show_h_grid: show_h_grid,
           legend_font_size: legend_font_size,
           legend_font_color: legend_font_color,
           plot_line_style: _plot_line_style,
           plot_line_width: _plot_line_width,
           grid_color: grid_color,
           grid_linestyle: grid_linestyle,
           grid_linewidth: grid_linewidth,
           x_padding: x_padding,
           y_padding: y_padding
         }
       ) do
    %Figure{
      figure
      | rc_params: %RcParams{
          rc_params
          | title_font: %Font{
              title_font
              | font_size: title_font_size,
                fill: title_font_color
            },
            x_label_font: %Font{
              x_label_font
              | font_size: x_label_font_size,
                fill: x_label_font_color
            },
            y_label_font: %Font{
              y_label_font
              | font_size: y_label_font_size,
                fill: y_label_font_color
            },
            x_tick_font: %Font{
              x_tick_font
              | font_size: x_tick_font_size,
                fill: x_tick_font_color
            },
            y_tick_font: %Font{
              y_tick_font
              | font_size: y_tick_font_size,
                fill: y_tick_font_color
            },
            legend_font: %Font{
              legend_font
              | font_size: legend_font_size,
                fill: legend_font_color
            },
            grid_color: grid_color,
            grid_linestyle: grid_linestyle,
            grid_linewidth: grid_linewidth,
            x_padding: x_padding,
            y_padding: y_padding
        },
        axes: %{
          axes
          | show_x_axis: show_x_axis,
            show_y_axis: show_x_axis,
            show_x_ticks: show_x_ticks,
            show_y_ticks: show_y_ticks,
            show_v_grid: show_v_grid,
            show_h_grid: show_h_grid,
            scale: %TwoD{x: x_scale, y: y_scale}
        }
    }
  end
end
