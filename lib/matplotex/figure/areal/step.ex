defmodule Matplotex.Figure.Areal.Step do

  alias Matplotex.Figure.Areal.LinePlot
  alias Matplotex.Figure
  alias Matplotex.InputError

  def create(x, y, opts) do
    {x, y} = step_segments(x, y)
    LinePlot.create(%Figure{axes: %LinePlot{}}, {x, y}, opts)
   end
   def create(%Figure{} = figure, x, y, opts) do
     {x, y} = step_segments(x, y)
     LinePlot.create(figure, {x, y}, opts)
   end
   defp step_segments(x, y) do
     x = horizontal_segments(x)
     y = vertical_segments(y)
     {x,y}
   end
   defp horizontal_segments(data) when is_list(data) do
     first_value = List.first(data)
     second_last_index = length(data) - 1
     repeated = data|>Enum.slice(1..second_last_index)|>List.duplicate(2)|> List.flatten()
     [first_value | repeated]|>Enum.sort()
   end
   defp horizontal_segments(_data), do: list_error(:y)

   defp vertical_segments(data) when is_list(data) do
     data|>List.duplicate(2)|>List.flatten()|>Enum.sort()
   end
   defp vertical_segments(_data), do: list_error(:y)

   defp list_error(arg) do
      raise InputError, message: "Expected a list for arg: #{arg}"
   end

end
