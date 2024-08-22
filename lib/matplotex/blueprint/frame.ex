defmodule Matplotex.Blueprint.Frame do
  @common_fields [
    :content,
    :dataset,
    :label,
    :scale,
    :grid,
    :title,
    :size,
    :tick,
    :margin,
    :valid,
    :axis,
    :element,
    :type
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

        @type frame_struct() :: %__MODULE__{
                dataset: dataset1_d() | dataset2_d(),
                label: label(),
                scale: scale(),
                grid: grid(),
                title: title(),
                size: size(),
                tick: tick(),
                margin: margin(),
                valid: valid(),
                axis: axis(),
                element: element(),
                type: module(),
                content: any()
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
