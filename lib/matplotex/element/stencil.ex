defmodule Matplotex.Element.Stencil do
  def sigil_L(line, []) do
    ~s(
    <line x1="#{line.x1}"
    y1="#{line.y1}"
    x2="#{line.x2}"
    y2="#{line.y2}"
    fill="#{line.fill}"
    stroke="#{line.stroke}"
    stroke-width="#{line.stroke_width}"
    shape-rendering="#{line.shape_rendering}"
    stroke-linecap="#{line.stroke_linecap}">
    )
  end

  def sigil_B(label, []) do
    ~s(
        <text tag="#{label.axis}"
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

  def sigil_Re(rect, []) do
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

  def sigil_Ti(tick, []) do
    ~s(
    #{~L(tick.tick_line)}
    #{~B(tick.label)}
    )
  end
end
