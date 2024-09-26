defmodule Matplotex.Figure do
  alias Matplotex.Figure.RcParams
  @row_column_default 1
  @margin_default 0.1
  @figsize {10, 6}
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

  def update_figure(figure, params) do
    if valid_params?(params) do
      Map.merge(figure, params)
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
    rc_params = Map.merge(rc_params, params)
    %{figure | rc_params: rc_params}
  end

  defp update_rc_params(_, _) do
    raise Matplotex.InputError, keys: [:rc_params], message: "Invalid Input"
  end
end
