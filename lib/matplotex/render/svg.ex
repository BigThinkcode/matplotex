defmodule Matplotex.Render.SVG do
  @moduledoc """
  Converts compiled chart geometry to an SVG string.

  This is the ONLY module that touches SVG syntax.
  All other modules work with typed `%Geom.*{}` structs (Nx tensors).

  ## Boundary rule

  `Nx.to_number/1` and `Nx.to_list/1` are called here and ONLY here.
  Everything upstream is Nx tensors.
  """

  alias Matplotex.{Chart, Frame, Axis}
  alias Matplotex.Geom.{Path, Rects, Circles, Arcs, Segments, Heatmap, TextLabels}

  @doc "Renders a compiled `%Chart{}` to an SVG string."
  def to_svg(%Chart{frame: frame} = chart) do
    canvas_w = Nx.to_number(frame.canvas_px[0])
    canvas_h = Nx.to_number(frame.canvas_px[1])

    plot = extract_plot(chart.frame)
    clip_id = "plot-clip"

    body =
      [
        render_background(chart),
        render_title(chart),
        render_grid(chart),
        render_axes(chart),
        render_axis_spines(chart),
        ~s(<defs><clipPath id="#{clip_id}"><rect x="#{plot.x}" y="#{plot.y}" width="#{plot.w}" height="#{plot.h}"/></clipPath></defs>),
        render_geometry(chart, clip_id)
      ]
      |> Enum.reject(&(&1 == ""))
      |> Enum.join("\n")

    ~s"""
    <svg xmlns="http://www.w3.org/2000/svg" width="#{canvas_w}" height="#{canvas_h}" style="font-family: sans-serif;">
    #{body}
    </svg>
    """
    |> String.trim()
  end

  # ── Background ────────────────────────────────────────────────────────────

  defp render_background(%Chart{canvas: %{background: nil}}), do: ""

  defp render_background(%Chart{canvas: canvas, frame: frame}) do
    w = Nx.to_number(frame.canvas_px[0])
    h = Nx.to_number(frame.canvas_px[1])
    ~s(<rect x="0" y="0" width="#{w}" height="#{h}" fill="#{canvas.background}"/>)
  end

  # ── Title ─────────────────────────────────────────────────────────────────

  defp render_title(%Chart{title: nil}), do: ""

  defp render_title(%Chart{title: title, frame: frame, canvas: canvas}) do
    t = frame.title
    cx = Nx.to_number(t[0]) + Nx.to_number(t[2]) / 2.0
    cy = Nx.to_number(t[1]) + canvas.title_font_size * 1.2
    ~s(<text x="#{cx}" y="#{cy}" text-anchor="middle" font-size="#{canvas.title_font_size}" font-weight="bold" fill="#222">#{title}</text>)
  end

  # ── Grid ──────────────────────────────────────────────────────────────────

  defp render_grid(%Chart{canvas: %{grid_style: :none}}), do: ""

  defp render_grid(%Chart{axes: axes, frame: frame, canvas: canvas}) do
    plot = extract_plot(frame)
    dash_attr = dasharray_attr(canvas.grid_style, :grid)

    lines =
      Enum.flat_map(axes, fn {axis_id, axis} ->
        pixels = tick_list(frame, axis_id)

        Enum.map(pixels, fn px ->
          case axis.dimension do
            :x ->
              ~s(<line x1="#{px}" y1="#{plot.y}" x2="#{px}" y2="#{plot.y + plot.h}" stroke="#{canvas.grid_color}" stroke-width="#{canvas.grid_width}"#{dash_attr}/>)
            _ ->
              ~s(<line x1="#{plot.x}" y1="#{px}" x2="#{plot.x + plot.w}" y2="#{px}" stroke="#{canvas.grid_color}" stroke-width="#{canvas.grid_width}"#{dash_attr}/>)
          end
        end)
      end)

    ~s(<g class="grid">\n#{Enum.join(lines, "\n")}\n</g>)
  end

  # ── Axis spine lines ──────────────────────────────────────────────────────

  defp render_axis_spines(%Chart{canvas: %{axis_line_style: :none}}), do: ""

  defp render_axis_spines(%Chart{axes: axes, frame: frame, canvas: canvas}) do
    plot = extract_plot(frame)
    color = canvas.axis_line_color
    sw = canvas.axis_line_width
    dash_attr = dasharray_attr(canvas.axis_line_style, :axis)

    spines =
      axes
      |> Map.values()
      |> Enum.map(fn axis ->
        case {axis.dimension, axis.position} do
          {:x, :bottom} ->
            y = plot.y + plot.h
            ~s(<line x1="#{plot.x}" y1="#{y}" x2="#{plot.x + plot.w}" y2="#{y}" stroke="#{color}" stroke-width="#{sw}"#{dash_attr}/>)
          {:x, :top} ->
            ~s(<line x1="#{plot.x}" y1="#{plot.y}" x2="#{plot.x + plot.w}" y2="#{plot.y}" stroke="#{color}" stroke-width="#{sw}"#{dash_attr}/>)
          {:y, :left} ->
            ~s(<line x1="#{plot.x}" y1="#{plot.y}" x2="#{plot.x}" y2="#{plot.y + plot.h}" stroke="#{color}" stroke-width="#{sw}"#{dash_attr}/>)
          {:y, :right} ->
            x = plot.x + plot.w
            ~s(<line x1="#{x}" y1="#{plot.y}" x2="#{x}" y2="#{plot.y + plot.h}" stroke="#{color}" stroke-width="#{sw}"#{dash_attr}/>)
          _ ->
            ""
        end
      end)
      |> Enum.reject(&(&1 == ""))

    ~s(<g class="axis-spines">\n#{Enum.join(spines, "\n")}\n</g>)
  end

  # ── Axes ──────────────────────────────────────────────────────────────────

  defp render_axes(%Chart{axes: axes, frame: frame, canvas: canvas}) do
    plot = extract_plot(frame)

    elements =
      Enum.flat_map(axes, fn {axis_id, axis} ->
        region = Map.get(frame.axis_regions, axis_id)
        pixels = tick_list(frame, axis_id)
        render_one_axis(axis, region, pixels, plot, canvas)
      end)

    ~s(<g class="axes">\n#{Enum.join(elements, "\n")}\n</g>)
  end

  defp render_one_axis(%Axis{dimension: :x, position: pos} = axis, region, pixels, plot, canvas)
       when pos in [:bottom, :top] do
    tick_y   = if pos == :bottom, do: plot.y + plot.h, else: plot.y
    tick_dir = if pos == :bottom, do: 1, else: -1

    ticks =
      Enum.zip(pixels, axis.tick_labels)
      |> Enum.flat_map(fn {px, label} ->
        label_y = tick_y + tick_dir * canvas.tick_font_size * 1.5
        text_el = render_x_tick_label(px, label_y, label, canvas.tick_font_size, axis.tick_label_rotation)
        [
          ~s(<line x1="#{px}" y1="#{tick_y}" x2="#{px}" y2="#{tick_y + tick_dir * 5}" stroke="#777" stroke-width="1"/>),
          text_el
        ]
      end)

    axis_label =
      if axis.label && region do
        cx     = plot.x + plot.w / 2.0
        label_y = Nx.to_number(region[1]) + Nx.to_number(region[3])
        [~s(<text x="#{cx}" y="#{label_y}" text-anchor="middle" font-size="#{canvas.label_font_size}" fill="#333">#{axis.label}</text>)]
      else
        []
      end

    ticks ++ axis_label
  end

  defp render_one_axis(%Axis{dimension: :y, position: pos} = axis, region, pixels, plot, canvas)
       when pos in [:left, :right] do
    {tick_x, dir, anchor} =
      if pos == :left,
        do:   {plot.x, -1, "end"},
        else: {plot.x + plot.w, 1, "start"}

    ticks =
      Enum.zip(pixels, axis.tick_labels)
      |> Enum.flat_map(fn {py, label} ->
        label_x = tick_x + dir * 8
        [
          ~s(<line x1="#{tick_x}" y1="#{py}" x2="#{tick_x + dir * 5}" y2="#{py}" stroke="#777" stroke-width="1"/>),
          ~s(<text x="#{label_x}" y="#{py + 4}" text-anchor="#{anchor}" font-size="#{canvas.tick_font_size}" fill="#444">#{label}</text>)
        ]
      end)

    axis_label =
      if axis.label && region do
        cy = plot.y + plot.h / 2.0
        lx =
          if pos == :left,
            do:   Nx.to_number(region[0]) + canvas.label_font_size,
            else: Nx.to_number(region[0]) + Nx.to_number(region[2]) - canvas.label_font_size
        rot = "rotate(-90,#{lx},#{cy})"
        [~s(<text x="#{lx}" y="#{cy}" transform="#{rot}" text-anchor="middle" font-size="#{canvas.label_font_size}" fill="#333">#{axis.label}</text>)]
      else
        []
      end

    ticks ++ axis_label
  end

  defp render_one_axis(_, _, _, _, _), do: []

  defp render_x_tick_label(px, label_y, label, fs, :horizontal) do
    ~s[<text x="#{px}" y="#{label_y}" text-anchor="middle" font-size="#{fs}" fill="#444">#{label}</text>]
  end

  defp render_x_tick_label(px, label_y, label, fs, :inclined) do
    ~s[<text x="#{px}" y="#{label_y}" text-anchor="end" font-size="#{fs}" fill="#444" transform="rotate(-45,#{px},#{label_y})">#{label}</text>]
  end

  defp render_x_tick_label(px, label_y, label, fs, :vertical) do
    ~s[<text x="#{px}" y="#{label_y}" text-anchor="end" font-size="#{fs}" fill="#444" transform="rotate(-90,#{px},#{label_y})">#{label}</text>]
  end

  defp render_x_tick_label(px, label_y, label, fs, deg) when is_number(deg) do
    anchor = if deg < 0, do: "end", else: "start"
    ~s[<text x="#{px}" y="#{label_y}" text-anchor="#{anchor}" font-size="#{fs}" fill="#444" transform="rotate(#{deg},#{px},#{label_y})">#{label}</text>]
  end

  # ── Geometry ──────────────────────────────────────────────────────────────

  defp render_geometry(%Chart{geometry: geometry}, clip_id) do
    Enum.with_index(geometry)
    |> Enum.map_join("\n", fn {geom_list, idx} ->
      inner = Enum.map_join(geom_list, "\n", &render_geom/1)
      ~s{<g class="series-#{idx}" clip-path="url(##{clip_id})">\n#{inner}\n</g>}
    end)
  end

  defp render_geom(%Path{coords: nil, svg_path_d: d} = g) do
    # Spline pre-built path
    ~s(<path d="#{d}" stroke="#{g.stroke}" fill="#{g.fill}" stroke-width="#{g.stroke_width}" opacity="#{g.opacity}"/>)
  end

  defp render_geom(%Path{coords: coords} = g) do
    d = coords_to_path_d(coords, g.closed)
    dash = if g.stroke_dasharray, do: ~s( stroke-dasharray="#{g.stroke_dasharray}"), else: ""
    ~s(<path d="#{d}" stroke="#{g.stroke}" fill="#{g.fill}" stroke-width="#{g.stroke_width}" opacity="#{g.opacity}"#{dash}/>)
  end

  defp render_geom(%Rects{xywh: xywh, fills: fills, stroke: stroke, opacity: opacity}) do
    xs = xywh[0] |> Nx.to_list()
    ys = xywh[1] |> Nx.to_list()
    ws = xywh[2] |> Nx.to_list()
    hs = xywh[3] |> Nx.to_list()

    fills_list = if is_list(fills), do: fills, else: List.duplicate(fills, length(xs))
    stroke_attr = if stroke, do: ~s( stroke="#{stroke}"), else: ""

    Enum.zip([xs, ys, ws, hs, fills_list])
    |> Enum.map_join("\n", fn {x, y, w, h, fill} ->
      ~s(<rect x="#{x}" y="#{y}" width="#{abs(w)}" height="#{abs(h)}" fill="#{fill}" opacity="#{opacity}"#{stroke_attr}/>)
    end)
  end

  defp render_geom(%Circles{cxcyr: cxcyr, fills: fills, opacity: opacity}) do
    cxs = cxcyr[0] |> Nx.to_list()
    cys = cxcyr[1] |> Nx.to_list()
    rs  = cxcyr[2] |> Nx.to_list()

    fills_list = if is_list(fills), do: fills, else: List.duplicate(fills, length(cxs))

    Enum.zip([cxs, cys, rs, fills_list])
    |> Enum.map_join("\n", fn {cx, cy, r, fill} ->
      ~s(<circle cx="#{cx}" cy="#{cy}" r="#{r}" fill="#{fill}" opacity="#{opacity}"/>)
    end)
  end

  defp render_geom(%Arcs{} = a) do
    {cx, cy} = a.center
    starts = Nx.to_list(a.start_angles)
    ends   = Nx.to_list(a.end_angles)
    ro     = a.outer_radius
    ri     = a.inner_radius

    Enum.zip([starts, ends, a.fills])
    |> Enum.map_join("\n", fn {sa, ea, fill} ->
      arc_path(cx, cy, ro, ri, sa, ea, fill, a.stroke, a.stroke_width)
    end)
  end

  defp render_geom(%Segments{x1y1x2y2: segs, stroke: stroke, stroke_width: sw, stroke_dasharray: dash}) do
    x1s = segs[0] |> Nx.to_list()
    y1s = segs[1] |> Nx.to_list()
    x2s = segs[2] |> Nx.to_list()
    y2s = segs[3] |> Nx.to_list()
    dash_attr = if dash, do: ~s( stroke-dasharray="#{dash}"), else: ""

    Enum.zip([x1s, y1s, x2s, y2s])
    |> Enum.map_join("\n", fn {x1, y1, x2, y2} ->
      ~s(<line x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}" stroke="#{stroke}" stroke-width="#{sw}"#{dash_attr}/>)
    end)
  end

  defp render_geom(%TextLabels{xy: xy, labels: labels, font_size: fs, anchor: anchor, fill: fill}) do
    xs = xy[0] |> Nx.to_list()
    ys = xy[1] |> Nx.to_list()

    Enum.zip([xs, ys, labels])
    |> Enum.map_join("\n", fn {x, y, label} ->
      ~s(<text x="#{x}" y="#{y}" text-anchor="#{anchor}" font-size="#{fs}" fill="#{fill}">#{label}</text>)
    end)
  end

  # ── SVG path helpers ──────────────────────────────────────────────────────

  defp coords_to_path_d(coords, closed) do
    xs = coords[0] |> Nx.to_list()
    ys = coords[1] |> Nx.to_list()

    [first_x | rest_xs] = xs
    [first_y | rest_ys] = ys

    moves =
      Enum.zip(rest_xs, rest_ys)
      |> Enum.map_join(" ", fn {x, y} -> "L #{x} #{y}" end)

    d = "M #{first_x} #{first_y} #{moves}"
    if closed, do: d <> " Z", else: d
  end

  defp arc_path(cx, cy, ro, ri, sa, ea, fill, stroke, sw) do
    x1 = cx + ro * :math.cos(sa)
    y1 = cy + ro * :math.sin(sa)
    x2 = cx + ro * :math.cos(ea)
    y2 = cy + ro * :math.sin(ea)

    large = if ea - sa > :math.pi(), do: 1, else: 0

    d =
      if ri > 0 do
        # Donut arc
        ix1 = cx + ri * :math.cos(ea)
        iy1 = cy + ri * :math.sin(ea)
        ix2 = cx + ri * :math.cos(sa)
        iy2 = cy + ri * :math.sin(sa)
        "M #{x1} #{y1} A #{ro} #{ro} 0 #{large} 1 #{x2} #{y2} " <>
          "L #{ix1} #{iy1} A #{ri} #{ri} 0 #{large} 0 #{ix2} #{iy2} Z"
      else
        "M #{cx} #{cy} L #{x1} #{y1} A #{ro} #{ro} 0 #{large} 1 #{x2} #{y2} Z"
      end

    ~s(<path d="#{d}" fill="#{fill}" stroke="#{stroke}" stroke-width="#{sw}"/>)
  end

  # ── Helpers ───────────────────────────────────────────────────────────────

  defp extract_plot(frame) do
    %{
      x: Nx.to_number(frame.plot[0]),
      y: Nx.to_number(frame.plot[1]),
      w: Nx.to_number(frame.plot[2]),
      h: Nx.to_number(frame.plot[3])
    }
  end

  defp tick_list(frame, axis_id) do
    case Map.get(frame.tick_pixels, axis_id) do
      nil    -> []
      tensor -> Nx.to_list(tensor)
    end
  end

  defp dasharray_attr(:solid, _),        do: ""
  defp dasharray_attr(:dashed, :grid),   do: ~s( stroke-dasharray="4 3")
  defp dasharray_attr(:dashed, :axis),   do: ~s( stroke-dasharray="8 4")
  defp dasharray_attr(:dotted, _),       do: ~s( stroke-dasharray="1 4")
  defp dasharray_attr(_, _),             do: ""
end
