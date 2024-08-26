# defmodule Matplotex.BarChart.GenerateSvg do
#   alias Matplotex.BarChart.Element
#   alias Matplotex.BarChart
#   import Matplotex.Element.Stencil

#   def add_bars(svg) do
#     svg_bars = ~s(<%= for bar <- chartset.element.bars do %>
#     <%= ~R(bar) %>
#     <% end %>)
#     [svg | svg_bars]
#   end

#   # TODO - add default values for fill, stroke,

#   def add_axis_lines(svg) do
#     axis_lines =
#       ~s(<%= for axis_line <- chartset.element.axis do %>
#      <%= ~L(axis_line) %>
#     <% end %>)

#     [svg | axis_lines]
#   end

#   def add_grid_lines(svg) do
#     grid_lines =
#       ~s(
#       <%= for grid_line <- chartset.element.grid do %>
#       <%= ~L(grid_line) %>
#       <% end %>
#       )

#     [svg | grid_lines]
#   end
#   def add_ticks(svg) do
#     ticks =
#       ~s(
#       <% for tick <- chartset.element.ticks do %>
#       <%= ~Ti(tick) %>
#       <% end %>
#        )
#   end

#   def generate_svg(barset, svg) do
#     eex_string =
#       svg
#       |>add_axis_lines()
#       |>add_grid_lines()
#       |>add_ticks()
#       |>bars()

#       EEx.eval_string(eex_string,barset)
#   end
# end
