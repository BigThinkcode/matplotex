defmodule Matplotex.BarChart.GenerateSvg do
  alias Matplotex.BarChart.Element
  alias Matplotex.BarChart

  def add_bars(svg) do
    svg_bars = ~s(<%= for bar <- chartset.element.bars do  %>
    <rect stroke="<%=bar.stroke%>"
    fill="<%=bar.color %>"
    x="<%=bar.x %>"
    y="<%=bar.y %>"
    width="<%=bar.width %>"
    height="<%=bar.height %>"
    stroke-width="<%=bar.stroke_width%>"
    filter="">
    </rect>
    <% end %>
    )
    [svg | svg_bars]
  end

  # TODO - add default values for fill, stroke,

  def add_axis_lines(svg) do
    axis_lines =
      ~s(<%= for axis_line <- chartset.element.axis do %>
    <line x1="<%=axis_line.x1 %>"
    y1="<%=axis_line.y1 %>"
    x2="<%=axis_line.x2 %>"
    y2="<%=axis_line.y2 %>"
    fill="<%=axis_line.fill%>"
    stroke="<%=axis_line.stroke%>"
    stroke-width="<%=axis_line.stroke_width%>"
    shape-rendering="<%=axis_line.shape_rendering%>"
    stroke-linecap="<%=axis_line.stroke_linecap%>"></line>
    <% end %>)

    [svg | axis_lines]
  end

  def add_grid_lines(svg) do
    grid_lines =
      ~s(
      <%= for grid_line <- changeset.element.grid do %>
      <line x1="<%=grid_line.x1 %>"
      y1="<%=grid_line.y1 %>"
      x2="<%=grid_line.x2 %>"
      y2="<%=grid_line.y2%>"
      stroke="<%=grid_line.stroke%>"
      fill="<%=grid_line.fill%>"
      stroke-width="<%=grid_line.stroke_width%>"
      shape-rendering="<%=grid_line.shape_rendering%>" >
      </line>
      <% end %>
      )

    [svg | grid_lines]
  end
end
