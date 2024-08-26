defmodule Matplotex.Element.Stencil do
  def line(line) do
    ~s(
    <line x1="#{line.x1}"
    y1="#{line.y1}"
    x2="#{line.x2}"
    y2="#{line.y2}"
    fill="#{line.fill}"
    stroke="#{line.stroke}"
    stroke-width="#{line.stroke_width}"
    shape-rendering="#{line.shape_rendering}"
    stroke-linecap="#{line.stroke_linecap}"/>

    )
  end

  def label(label) do
    ~s(
        <text tag="#{label.type}"
         fill="#{label.fill}"
         x="#{label.x}"
         y="#{label.y}"
         font-size="#{label.font_size}"
         font-weight="#{label.font_weight}"
         font-family="#{label.font_family}"
         font-style="#{label.font_style}"
         dominant-baseline="#{label.dominant_baseline}">
         #{label.text}
        </text>
    )
  end

  def rect(rect) do
    ~s(
    <rect stroke="#{rect.stroke}"
    fill="#{rect.color}"
    x="#{rect.x}"
    y="#{rect.y}"
    width="#{rect.width}"
    height="#{rect.height}"
    stroke-width="#{rect.stroke_width}"
    filter="">
    </rect>)
  end

  def tick(tick) do
    ~s(
    #{line(tick.tick_line)}
    #{label(tick.label)}
    )
  end
end
