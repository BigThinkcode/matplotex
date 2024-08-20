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
  defmacro frame(fields) do
    build_struct(fields)
  end

  defp build_struct(fields) do
    reg =
      quote do
        Module.register_attribute(__MODULE__, :frame_struct_fields, accumulate: true)
      end

    types =
      quote do
        @type dataset1_d() :: list() | nil
        @type dataset2_d() :: %{x: list(), y: list()} | nil
        @type font() :: %{size: String.t()| nil, weight: String.t()| nil, color: String.t()| nil} | nil
        @type label() :: %{x: String.t() | nil, y: String.t() | nil, font: font() | nil} | nil
        @type scale() :: %{x: number() | nil, y: number() | nil, aspect_ratio: number | nil} | nil
        @type grid() :: %{x_scale: number() | nil, y_scale: number() | nil} | nil
        @type title() :: %{title: String.t() | nil, font_size: font() | nil} | nil
        @type size() :: %{height: number()| nil, width: number()| nil} | nil
        @type tick() :: %{x_scale: number() | nil, y_scale: number() | nil, font: font()| nil}| nil
        @type margin() :: %{x_margin: number()| nil, y_margin: number()| nil} | nil
        @type valid() :: :ok | {:error, String.t()}| nil
        @type axis() :: :on | :off | nil
        @type element() :: any()

        @type frame() :: %{
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
                type: module()
              }
      end

    # IO.inspect(@frame_struct_fields)
    # Module.put_attribute(__MODULE__, :frame_field_types, unquote(@field_ypes))
    prequest =
      quote do
        Module.put_attribute(__MODULE__, :frame_struct_fields, unquote(@common_fields))
        Module.put_attribute(__MODULE__, :frame_struct_fields, unquote(fields))
      end

    postquest =
      quote unquote: false do
        defstruct @frame_struct_fields |> Enum.reverse() |> List.flatten()
      end

    quote do
      unquote(types)
      unquote(reg)
      unquote(prequest)
      unquote(postquest)
    end
  end
end
