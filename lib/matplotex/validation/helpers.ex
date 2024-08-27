defmodule Matplotex.Validation.Helpers do
  alias Matplotex.InputError

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
end
