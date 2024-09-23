defmodule Matplotex.Blueprint.Frame do
  @default_margin 10
  @show_by_default true
  @valid_by_default true
  @common_fields [
    :id,
    :content,
    :data,
    :dataset, #TODO: change dataset to data, should deprecat this field
    :label,
    :scale,
    :grid,
    :title,
    :size,
    :tick,
    :axis,
    :element,
    :type,
    :grid_coordinates,
    :x_lim,
    :y_lim,
    errors: [],
    valid: @valid_by_default,
    margin: @default_margin,
    show_x_axis: @show_by_default,
    show_y_axis: @show_by_default,
    show_v_grid: @show_by_default,
    show_h_grid: @show_by_default,
    show_ticks: @show_by_default,
  ]
  defmacro frame() do
    build_struct()
  end

  defp build_struct() do
    types =
      quote do
        @type dataset1_d() :: list() | nil
        @type dataset2_d() :: %{x: list(), y: list()} | nil
        @type font() ::
                %{size: String.t() | nil, weight: String.t() | nil, color: String.t() | nil} | nil
        @type label() :: %{x: String.t() | nil, y: String.t() | nil, font: font() | nil} | nil
        @type scale() :: %{x: number() | nil, y: number() | nil, aspect_ratio: number | nil} | nil
        @type grid() :: %{x_scale: number() | nil, y_scale: number() | nil} | nil
        @type title() :: %{title: String.t() | nil, font_size: font() | nil} | nil
        @type size() :: %{height: number() | nil, width: number() | nil} | nil
        @type tick() ::
                %{x_scale: number() | nil, y_scale: number() | nil, font: font() | nil} | nil
        @type margin() :: %{x_margin: number() | nil, y_margin: number() | nil} | nil
        @type valid() :: :ok | {:error, String.t()} | nil
        @type axis() :: :on | :off | nil
        @type element() :: any()
        @type content() :: any()
        @type limit() :: {number(), number()} | any()


        @type frame_struct() :: %__MODULE__{
                id: any(),
                dataset: dataset1_d() | dataset2_d(),
                data: any(),
                label: label(), # set xlabel set y label
                scale: scale(),
                grid: grid(),
                title: title(),
                size: size(),
                tick: tick(),
                margin: margin(),
                valid: valid(),
                axis: axis(),
                element: element(),
                type: String.t(),
                content: any(),
                show_x_axis: boolean(),
                show_y_axis: boolean(),
                show_v_grid: boolean(),
                show_h_grid: boolean(),
                errors: list(),
                grid_coordinates: dataset2_d(),
                show_ticks: boolean(),
                x_lim: limit(),
                y_lim: limit()
              }
      end

    build_struct =
      quote do
        defstruct unquote(@common_fields)
      end

    quote do
      unquote(types)
      unquote(build_struct)
    end
  end
end
