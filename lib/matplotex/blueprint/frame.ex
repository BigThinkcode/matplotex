defmodule Matplotex.Blueprint.Frame do
  alias Matplotex.Figure.Legend
  @default_margin 0.05
  @show_by_default true
  @valid_by_default true
  defmacro frame(opts \\ []) do
    build_struct(opts)
  end

  defp build_struct(opts) do
    types =
      quote do
        @type dataset1_d() :: list() | nil
        @type dataset2_d() :: %{x: list(), y: list()} | nil
        @type font() ::
                %{size: String.t() | nil, weight: String.t() | nil, color: String.t() | nil} | nil
        @type label() :: %{x: String.t() | nil, y: String.t() | nil, font: font() | nil} | nil
        @type scale() :: %{x: number() | nil, y: number() | nil, aspect_ratio: number | nil} | nil
        @type grid() :: %{x_scale: number() | nil, y_scale: number() | nil} | nil
        @type title() ::
                %{title: String.t() | nil, font_size: font() | nil, height: number() | nil} | nil
        @type size() :: %{height: number() | nil, width: number() | nil} | nil
        @type tick() ::
                %{x_scale: number() | nil, y_scale: number() | nil, font: font() | nil} | nil
        @type margin() :: %{x_margin: number() | nil, y_margin: number() | nil} | nil
        @type valid() :: :ok | {:error, String.t()} | nil
        @type axis() :: :on | :off | nil
        @type element() :: any()
        @type content() :: any()
        @type limit() :: %{x: number(), y: number()} | any()
        @type legend() :: Legend.t() | any()

        @type frame_struct() :: %__MODULE__{
                id: any(),
                dataset: dataset1_d() | dataset2_d(),
                data: any(),
                # set xlabel set y label
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
                type: String.t(),
                content: any(),
                show_x_axis: boolean(),
                show_y_axis: boolean(),
                show_v_grid: boolean(),
                show_h_grid: boolean(),
                errors: list(),
                grid_coordinates: dataset2_d(),
                show_ticks: boolean(),
                limit: limit(),
                legend: legend()
              }
      end

    build_struct =
      quote do
        defstruct unquote(
                    [
                      id: "chart-matplotex",
                      # Deprecated
                      content: nil,
                      label: nil,
                      scale: nil,
                      grid: nil,
                      size: nil,
                      axis: nil,
                      center: nil,
                      type: nil,
                      grid_coordinates: nil,
                      data: nil,
                      dataset: [],
                      title: nil,
                      tick: nil,
                      limit: nil,
                      coords: nil,
                      legend: nil,
                      dimension: nil,
                      errors: [],
                      element: [],
                      show_title: false,
                      valid: @valid_by_default,
                      margin: @default_margin,
                      show_x_axis: @show_by_default,
                      show_y_axis: @show_by_default,
                      show_v_grid: @show_by_default,
                      show_h_grid: @show_by_default,
                      show_x_ticks: @show_by_default,
                      show_y_ticks: @show_by_default,
                      show_ticks: @show_by_default
                    ]
                    |> Keyword.merge(opts)
                  )
      end

    quote do
      unquote(types)
      unquote(build_struct)
    end
  end
end
