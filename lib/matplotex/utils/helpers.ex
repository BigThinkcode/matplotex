defmodule Matplotex.Utils.Helpers do
  @moduledoc """
  Module contains some misslenious helper functions
  """

  @doc """
  Input params may contains params for that chart struct and params for
  content struct this functions sgregates that and return a tuple with
  params for chart struct and content struct.
  ### Params
  * params - Map contains input params
  * content_fields - list of atoms contains field names
  """

  @spec segregate_content(any(), list()) :: {any(), any()}
  def segregate_content(params, content_fields) do
    Enum.reduce(content_fields, {params, %{}}, fn field, {sparams, content_params} ->
      {content, tparams} = Map.pop(sparams, field)
      {tparams, Map.put(content_params, field, content)}
    end)
  end

  def fetch_errors(graphset) do
    Map.get(graphset, :errors, [])
  end
end
