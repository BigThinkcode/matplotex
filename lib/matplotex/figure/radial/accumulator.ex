defmodule Matplotex.Figure.Radial.Accumulator do
alias Matplotex.Figure.Radial.Legend

  @start_angle -:math.pi() / 2
  defstruct [slices: [], legend: %Legend{}, lead: {}, legends: [], labels: [], start_angle: @start_angle]

end
