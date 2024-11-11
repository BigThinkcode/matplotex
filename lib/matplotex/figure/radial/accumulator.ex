defmodule Matplotex.Figure.Radial.Accumulator do
  alias Matplotex.Figure.Radial.LegendAcc

  @start_angle :math.pi() / 2
  defstruct slices: [],
            lead: {},
            legends: [],
            labels: [],
            start_angle: @start_angle,
            legend_acc: %LegendAcc{}
end
