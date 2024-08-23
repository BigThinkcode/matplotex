defmodule Matplotex.FrameHelpers do
  def new(module, params), do: module.new(params)

  def set_content(module, chartset), do: module.set_content(chartset)
end
