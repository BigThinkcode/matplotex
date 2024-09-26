defmodule Matplotex.Figure.RcParams do
  @default_figsize {8, 6}
  @default_dpi 100
  @line_width 2
  @line_style "-"
  @grid_color "#ddd"
  @grid_linestyle "--"

  @legend_location "top right"
  @default_font_size "16pt"
  defstruct figure_size: @default_figsize,
            figure_dpi: @default_dpi,
            line_width: @line_width,
            line_style: @line_style,
            x_tick_font_size: @default_font_size,
            y_tick_font_size: @default_font_size,
            x_label_font_size: @default_font_size,
            y_label_font_size: @default_font_size,
            legend_font_size: @default_font_size,
            legend_location: @legend_location,
            title_font: @default_font_size,
            grid_color: @grid_color,
            grid_linestyle: @grid_linestyle
end
