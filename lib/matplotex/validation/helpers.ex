defmodule Matplotex.Validation.Helpers do
  alias Matplotex.InputError

 #TODO: Move module specific validators to particular module
  def validator() do
    %{
      "id" => fn id -> is_binary(id) end,
      "title" => fn title -> is_binary(title) end,
      "stroke_width" => fn sw -> is_binary(sw) or is_number(sw) end,
      "legends" => fn legends -> is_boolean(legends) end,
      "dataset" => fn dataset -> validate_dataset(dataset) end,
      "x_labels" => fn x_labels -> is_list(x_labels) end,
      "color_palette" => fn color_palette ->
        is_list(color_palette) or is_binary(color_palette)
      end,
      "width" => fn width -> is_a_space(width) end,
      "height" => fn height -> is_a_space(height) end,
      "x_margin" => fn x_margin -> is_a_space(x_margin) end,
      "y_margin" => fn y_margin -> is_a_space(y_margin) end,
      "y_scale" => fn y_scale -> is_a_space(y_scale) end,
      "x_scale" => fn y_scale -> is_a_space(y_scale) end,
      "y_label_suffix" => fn yls -> is_binary(yls) end,
      "y_label_offset" => fn ylo -> is_a_space(ylo) end,
      "x_label_offset" => fn xlo -> is_a_space(xlo) end,
      "labels" => fn labels -> is_list(labels) end,
      "margin" => fn margin -> is_a_space(margin) end,
      "line_width" => fn line_width -> is_a_space(line_width) end,
      "show_x_axis" => fn show_x_axis -> is_boolean(show_x_axis) end,
      "show_y_axis" =>  fn show_y_axis -> is_boolean(show_y_axis) end,
      "show_v_grid" => fn show_v_grid -> is_boolean(show_v_grid) end,
      "show_h_grid" => fn show_h_grid -> is_boolean(show_h_grid) end
    }
  end

    def run_validator(true, validator, params) do
    Enum.filter(params, fn {k, v} ->
      validator_fun = Map.get(validator, k)

      unless validator_fun.(v) do
        {k, v}
      end
    end)
    |> do_validate(params)
  end

  def run_validator(false, validator, params) do
    keys = Map.keys(params) -- Map.keys(validator)
    raise Matplotex.InputError, keys: keys, message: "Unwanted inputs #{inspect(keys)}"
  end

  defp do_validate(result, params) do
    if length(result) == 0 do
      {:ok, params}
    else
      raise InputError, keys: result, message: "Invalid input #{inspect(result)}"
    end
  end

  def validate_dataset(dataset) when is_list(dataset) do
    dataset
    |> List.flatten()
    |> Enum.filter(fn value ->
      !is_number(value)
    end)
    |> length() == 0
  end

  def validate_dataset(_), do: false

  def validate_params(params) do
    validator()
    |> validate_keys(params)
    |> run_validator(validator(), params)
  end

  defp validate_keys(validator, params) do
    params_keys = keys_mapset(params)
    validator_keys = keys_mapset(validator)
    MapSet.subset?(params_keys, validator_keys)
  end

  defp keys_mapset(map) do
    map
    |> Map.keys()
    |> MapSet.new()
  end

  defp is_a_space(value), do: is_number(value) and value >= 0
end
