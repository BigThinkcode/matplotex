defmodule Matplotex.Figure.RcParams do
  alias Matplotex.Figure.Font
  @default_figsize {8, 6}
  @default_dpi 100
  @line_width 2
  @line_style "-"
  @grid_color "#ddd"
  @grid_linestyle "--"

  @legend_location "top right"
  @default_font_size 16
  @default_title_font_size 18
  @grid_linewidth 1
  @grid_line_alpha 0.5
  @font_uom "pt"
  @tick_line_length 5
  @font %Font{}
  defstruct x_tick_font: @font,
            y_tick_font: @font,
            x_label_font: @font,
            y_label_font: @font,
            title_font: %Font{font_size: @default_title_font_size},
            legend_font: @font,
            figure_size: @default_figsize,
            figure_dpi: @default_dpi,
            line_width: @line_width,
            line_style: @line_style,
            x_tick_font_size: @default_font_size,
            y_tick_font_size: @default_font_size,
            x_label_font_size: @default_font_size,
            y_label_font_size: @default_font_size,
            legend_font_size: @default_font_size,
            legend_location: @legend_location,
            title_font_size: @default_title_font_size,
            grid_color: @grid_color,
            grid_linestyle: @grid_linestyle,
            grid_linewidth: @grid_linewidth,
            grid_alpha: @grid_line_alpha,
            font_uom: @font_uom,
            tick_line_length: @tick_line_length

  def get_rc(%__MODULE__{} = rc_param, get_func) do
    apply(__MODULE__, get_func, [rc_param])
  end

  def get_rc(_, _), do: raise(ArgumentError)

  def get_x_label_font_size(%__MODULE__{x_label_font_size: nil}) do
    @default_font_size
  end

  def get_x_label_font_size(%__MODULE__{x_label_font_size: x_label_font_size})
      when is_number(x_label_font_size) do
    x_label_font_size
  end

  def get_x_label_font_size(%__MODULE__{x_label_font_size: x_label_font_size}),
    do: convert_font_size(x_label_font_size)

  def get_y_label_font_size(%__MODULE__{y_label_font_size: nil}) do
    @default_font_size
  end

  def get_y_label_font_size(%__MODULE__{y_label_font_size: y_label_font_size})
      when is_number(y_label_font_size) do
    y_label_font_size
  end

  def get_y_label_font_size(%__MODULE__{y_label_font_size: y_label_font_size}),
    do: convert_font_size(y_label_font_size)

  def get_title_font_size(%__MODULE__{title_font_size: nil}), do: @default_title_font_size

  def get_title_font_size(%__MODULE__{title_font_size: title_font_size})
      when is_number(title_font_size),
      do: title_font_size

  def get_title_font_size(%__MODULE__{title_font_size: title_font_size}) do
    convert_font_size(title_font_size)
  end

  def get_x_tick_font_size(%__MODULE__{x_tick_font_size: nil}), do: @default_font_size

  def get_x_tick_font_size(%__MODULE__{x_tick_font_size: x_tick_font_size})
      when is_number(x_tick_font_size) do
    x_tick_font_size
  end

  def get_x_tick_font_size(%__MODULE__{x_tick_font_size: x_tick_font_size}) do
    convert_font_size(x_tick_font_size)
  end

  def get_y_tick_font_size(%__MODULE__{y_tick_font_size: nil}), do: @default_font_size

  def get_y_tick_font_size(%__MODULE__{y_tick_font_size: y_tick_font_size})
      when is_number(y_tick_font_size) do
    y_tick_font_size
  end

  def get_y_tick_font_size(%__MODULE__{y_tick_font_size: y_tick_font_size}) do
    convert_font_size(y_tick_font_size)
  end

  def get_tick_line_length(%__MODULE__{tick_line_length: tick_line_length}) do
    tick_line_length
  end

  def get_title_font(%__MODULE__{title_font: title_font}) do
    title_font
  end

  defp convert_font_size(<<font_size::binary-size(2)>> <> "pt") do
    String.to_integer(font_size)
  end

  defp convert_font_size(font_size) when is_binary(font_size) do
    String.to_integer(font_size)
  end

  defp convert_font_size(font_size) when is_number(font_size) do
    font_size
  end
end
