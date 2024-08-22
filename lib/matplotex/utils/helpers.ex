defmodule Matplotex.Utils.Helpers do
  def segregate_content(params, content_fields) do
    Enum.reduce(content_fields,{params, %{}}, fn field, {params, content_params} ->
      {content, params} = Map.pop(params, field)
      {params,Map.put(content_params, field, content) }
    end)
  end
end
