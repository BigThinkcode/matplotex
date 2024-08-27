defmodule Matplotex.Utils.Helpers do
  def segregate_content(params, content_fields) do
    Enum.reduce(content_fields, {params, %{}}, fn field, {sparams, content_params} ->
      {content, tparams} = Map.pop(sparams, field)
      {tparams, Map.put(content_params, field, content)}
    end)
  end
end
