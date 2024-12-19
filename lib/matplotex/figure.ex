defmodule Matplotex.Figure do
  alias Matplotex.Figure.RcParams
  @row_column_default 1
  @margin_default 0.05
  @figsize {10, 6}

  @restricted_keys [:axes, :element, :valid?, :rc_params, :errors]
  defstruct [
    :id,
    :axes,
    :element,
    valid?: true,
    rc_params: %RcParams{},
    errors: [],
    figsize: @figsize,
    rows: @row_column_default,
    columns: @row_column_default,
    margin: @margin_default
  ]

  @type t() :: %__MODULE__{
          id: String.t(),
          axes: any(),
          element: any(),
          valid?: boolean(),
          errors: [String.t()],
          figsize: {float(), float()},
          rc_params: any(),
          rows: integer(),
          columns: integer(),
          margin: float()
        }
  def new(opts) do
    struct(__MODULE__, opts)
  end

  def restricted_keys(), do: @restricted_keys

  # TODO: put error message in error
  # def put_error(figure, opts) do

  # end

  def add_label(%__MODULE__{axes: %module{} = axes} = figure, label, opts),
    do: %{figure | axes: module.add_label(axes, label, opts)}

  def add_title(%__MODULE__{axes: %module{} = axes} = figure, title, opts),
    do: %{figure | axes: module.add_title(axes, title, opts)}

  def add_ticks(%__MODULE__{axes: %module{} = axes} = figure, ticks),
    do: %{figure | axes: module.add_ticks(axes, ticks)}

  def set_limit(%__MODULE__{axes: %module{} = axes} = figure, limit),
    do: %{figure | axes: module.set_limit(axes, limit)}

  def add_legend(%__MODULE__{axes: %module{} = axes} = figure, params),
    do: %{figure | axes: module.add_legend(axes, params)}

  def hide_v_grid(%__MODULE__{axes: %module{} = axes} = figure),
    do: %{figure | axes: module.hide_v_grid(axes)}

  def show_legend(%__MODULE__{axes: %module{} = axes} = figure),
    do: %{figure | axes: module.show_legend(axes)}

  def set_figure_size(%__MODULE__{margin: margin, axes: axes} = figure, {fwidth, fheight} = fsize) do
    frame_size = {fwidth - fwidth * 2 * margin, fheight - fheight * 2 * margin}

    %{figure | figsize: fsize, axes: %{axes | size: frame_size}}
  end

  def set_margin(%__MODULE__{figsize: {fwidth, fheight}, axes: axes} = figure, margin) do
    frame_size = {fwidth - fwidth * 2 * margin, fheight - fheight * 2 * margin}
    %__MODULE__{figure | margin: margin, axes: %{axes | size: frame_size}}
  end

  def materialize(%__MODULE__{axes: %module{}} = figure), do: module.materialize(figure)

  def update_figure(figure, params) do
    if valid_params?(params) do
      struct(figure, params)
    else
      raise Matplotex.InputError, message: "Invalid keys"
    end
  end

  defp valid_params?(params) do
    param_keys = Map.keys(params)
    fig_keys = Map.keys(%__MODULE__{})
    Enum.any?(param_keys, fn key -> key in fig_keys end)
  end

  def set_rc_params(figure, params) when is_list(params) do
    params = Enum.into(params, %{})
    update_rc_params(figure, params)
  end

  def set_rc_params(figure, params) when is_map(params) do
    params =
      if string_keys?(params) do
        Enum.reduce(params, %{}, fn {k, v}, acc ->
          Map.put(acc, String.to_atom(k), v)
        end)
      else
        params
      end

    update_rc_params(figure, params)
  end

  defp string_keys?(params) do
    Enum.all?(Map.keys(params), fn k -> is_binary(k) end)
  end

  defp update_rc_params(%__MODULE__{rc_params: rc_params} = figure, params) do
    rc_params = rc_params |> struct(params) |> RcParams.update_with_font(params)
    %{figure | rc_params: rc_params}
  end

  defp update_rc_params(_, _) do
    raise Matplotex.InputError, keys: [:rc_params], message: "Invalid Input"
  end
end
