defmodule Matplotex.Figure.TwoD do
  defstruct [:x, :y]

  def update(twod, opts, context) do
    %__MODULE__{
      twod
      | x: fetch_from_opts(opts, :x, context),
        y: fetch_from_opts(opts, :y, context)
    }
  end

  defp fetch_from_opts(opts, key, context) do
    Map.get(opts, :"#{key}_#{context}")
  end
end
