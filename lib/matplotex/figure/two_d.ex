defmodule Matplotex.Figure.TwoD do
  defstruct [:x, :y]

  def update(%__MODULE__{x: x, y: y} = twod, opts, context) do
    %__MODULE__{
      twod
      | x: fetch_from_opts(opts, :x, context) || x,
        y: fetch_from_opts(opts, :y, context) || y
    }
  end

  defp fetch_from_opts(opts, key, context) do
    Map.get(opts, :"#{key}_#{context}")
  end
end
