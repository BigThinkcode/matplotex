defmodule Matplotex.Figure.RcParams do
  alias Matplotex.Figure.Font
  @default_figsize {8, 6}
  @default_dpi 96
  @line_width 2
  @line_style "_"
  @grid_color "#ddd"
  @grid_linestyle "--"

  @legend_location "top right"
  @default_font_size 16
  @default_title_font_size 18
  @grid_linewidth 1
  @grid_line_alpha 0.5
  @font_uom "pt"
  @tick_line_length 5 / 96
  @font %Font{}
  @chart_padding 0.05
  @label_padding 5 / 96
  @default_legend_width_percentage 0.2
  @default_legend_items_orientation :horizontal
  defstruct x_tick_font: %Font{dominant_baseline: "middle"},
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
            tick_line_length: @tick_line_length,
            x_padding: @chart_padding,
            y_padding: @chart_padding,
            label_padding: @label_padding,
            legend_width: @default_legend_width_percentage,
            legend_items_orientation: @default_legend_items_orientation

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

  def get_x_label_font(%__MODULE__{x_label_font: x_label_font}) do
    x_label_font
  end

  def get_y_label_font(%__MODULE__{y_label_font: y_label_font}) do
    y_label_font
  end

  def update_with_font(rc_params, params) do
    rc_params
    |> update_font(params, :x_label)
    |> update_font(params, :y_label)
    |> update_font(params, :x_tick)
    |> update_font(params, :y_tick)
    |> update_font(params, :title)
  end

  defp update_font(
         rc_params,
         params,
         element
       ) do
    element_font_keys = font_associated_keys(element)
    element_params = Map.take(params, element_font_keys)

    font = Map.get(rc_params, :"#{element}_font")
    updated_font = Font.update(font, element_params, element)
    Map.put(rc_params, :"#{element}_font", updated_font)
  end

  # defp update_font(
  #        %__MODULE__{y_label_font: y_label_font} = rc_params,
  #        %{y_label_font_size: y_label_font_size},
  #        :y_label_font
  #      ) do
  #   %__MODULE__{
  #     rc_params
  #     | y_label_font: Font.update(y_label_font, %{font_size: y_label_font_size})
  #   }
  # end

  # defp update_font(
  #        %__MODULE__{x_tick_font: x_tick_font} = rc_params,
  #        %{x_tick_font_size: x_tick_font_size},
  #        :x_tick_font
  #      ) do
  #   %__MODULE__{rc_params | x_tick_font: Font.update(x_tick_font, %{font_size: x_tick_font_size})}
  # end

  # defp update_font(
  #        %__MODULE__{y_tick_font: y_tick_font} = rc_params,
  #        %{y_tick_font_size: y_tick_font_size},
  #        :y_tick_font
  #      ) do
  #   %__MODULE__{rc_params | y_tick_font: Font.update(y_tick_font, %{font_size: y_tick_font_size})}
  # end

  # defp update_font(
  #        %__MODULE__{title_font: title_font} = rc_params,
  #        %{title_font_size: title_font_size},
  #        :title_font
  #      ) do
  #   %__MODULE__{rc_params | title_font: Font.update(title_font, %{font_size: title_font_size})}
  # end

  # defp update_font(rc_params, _, _), do: rc_params

  def font_associated_keys(element) do
    %Font{}
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.map(fn fkey ->
      :"#{element}_#{fkey}"
    end)
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
