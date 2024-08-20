defmodule Matplotex.Blueprint.Frame do
  @type dataset1_d() :: %{x: list()}
  @type dataset2_d() :: %{x: list(), y: list()}
  @type font() :: %{size: String.t(), weight: String.t(), color: String.t()}
  @type label() :: %{x: String.t() | nil, y: String.t() | nil, font: font() | nil}
  @type scale() :: %{x: number() | nil, y: number() | nil, aspect_ratio: number | nil}
  @type grid() :: %{x_scale: number() | nil, y_scale: number() | nil} | nil
  @type title() :: %{title: String.t() | nil, font_size: font() | nil}
  @type size() :: %{height: number(), width: number()} | nil
  @type tick() :: %{x_scale: number() | nil, y_scale: number() | nil, font: font()}
  @type margin() :: %{x_margin: number(), y_margin: number()} | nil
  @type valid() :: :ok | {:error, String.t()}
  @type axis() :: :on | :off
  @type element() :: any()

  # @field_ypes [
  #         dataset: {dataset1_d() , dataset2_d()},
  #         label: label(),
  #         scale: scale(),
  #         grid: grid(),
  #         title: title(),
  #         size: size(),
  #         tick: tick(),
  #         margin: margin(),
  #         valid: valid(),
  #         axis: axis(),
  #         element: element(),
  #         type: module()
  # ]

  @common_fields [
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
  defmacro frame(name, do: block) do
    build_struct(name, block)
  end

  def build_struct(name, block) do
    prequest =
      quote do
        try do
          import Matplotex.Blueprint.Frame
          unquote(block)
        after
          :ok
        end
      end

    postquest =
      quote unquote: false do
        defstruct Enum.reverse(@frame_struct_fields)
        # @type t() :: generate_type()
      end

    quote do
      unquote(prequest)
      unquote(postquest)
    end
  end

  defmacro __before_compile__(_) do
    quote do
      Module.register_attribute(__MODULE__, :fame_struct_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :frame_field_types, accumulate: true)
      Module.put_attribute(__MODULE__, :frame_struct_fields, unquote(@common_fields))
      IO.inspect(@frame_struct_fields)
      IO.inspect(@frame_struct_fields)
      Module.put_attribute(__MODULE__, :frame_field_types, unquote(@field_ypes))
    end
  end

  # defp generate_type() do
  #   types = Module.get_attribute(__MODULE__, :frame_struct_fields)
  #   map = Map.from_keys(Keyword.keys(types), Keyword.values(types))
  #   Map.merge(%__MODULE__{}, map)
  # end

  defmacro field(name) do
    quote do
      Module.put_attribute(__MODULE__, :frame_struct_fields, unquote(name))
      IO.inspect(@frame_struct_fields)
      # Module.put_attribute(:frame_field_types, {name, unquote(type)})
    end
  end

  # def new(params), do: Map.merge(%__MODULE__{}, params)
end
