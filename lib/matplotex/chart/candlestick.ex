defmodule Matplotex.Chart.Candlestick do
  @moduledoc """
  Candlestick chart — OHLC bars for financial data.

  Data format: `dataset.x` = time (epoch seconds), `dataset.y` = close price.
  `dataset.extra` must contain: `%{open: tensor, high: tensor, low: tensor}`.
  """
  @behaviour Matplotex.Chart.Behaviour

  alias Matplotex.{Dataset, Frame, Scale, Geom}

  @candle_width_fraction 0.6

  @impl true
  def to_geometry(
        %Dataset{x: x, y: close, extra: %{open: open, high: high, low: low}, color: _color},
        transform,
        %Frame{plot: plot}
      ) do
    n = Nx.size(x)
    pw = Nx.to_number(plot[2])
    candle_w = pw / max(n, 1) * @candle_width_fraction

    ones  = Nx.broadcast(Nx.tensor(1.0, type: :f64), {n})

    map_y = fn y_t ->
      px = Scale.apply(transform, Nx.stack([x, y_t, ones]))
      px[1]
    end

    px_x    = Scale.apply(transform, Nx.stack([x, close, ones]))[0]
    py_open  = map_y.(open)
    py_close = map_y.(close)
    py_high  = map_y.(high)
    py_low   = map_y.(low)

    x_list     = Nx.to_list(px_x)
    open_list  = Nx.to_list(py_open)
    close_list = Nx.to_list(py_close)
    high_list  = Nx.to_list(py_high)
    low_list   = Nx.to_list(py_low)

    half_w = candle_w / 2.0

    {body_rects, wick_segs, bull_rects, bear_rects} =
      Enum.zip([x_list, open_list, close_list, high_list, low_list])
      |> Enum.reduce({[], [], [], []}, fn {px, po, pc, ph, pl}, {_bodies, wicks, bulls, bears} ->
        body_top    = min(po, pc)
        body_bottom = max(po, pc)
        body_h      = max(body_bottom - body_top, 1.0)

        wick = [px, ph, px, pl]
        rect = [px - half_w, body_top, candle_w, body_h]

        if pc <= po do
          # Bullish (close ≥ open): green
          {[], wicks ++ [wick], bulls ++ [rect], bears}
        else
          # Bearish (close < open): red
          {[], wicks ++ [wick], bulls, bears ++ [rect]}
        end
      end)

    geoms = []

    geoms =
      if wick_segs != [] do
        t = wick_segs |> Nx.tensor(type: :f64) |> Nx.transpose()
        [%Geom.Segments{x1y1x2y2: t, stroke: "#555555", stroke_width: 1} | geoms]
      else
        geoms
      end

    geoms =
      if bull_rects != [] do
        t = bull_rects |> Nx.tensor(type: :f64) |> Nx.transpose()
        [%Geom.Rects{xywh: t, fills: "#26a69a"} | geoms]
      else
        geoms
      end

    geoms =
      if bear_rects != [] do
        t = bear_rects |> Nx.tensor(type: :f64) |> Nx.transpose()
        [%Geom.Rects{xywh: t, fills: "#ef5350"} | geoms]
      else
        geoms
      end

    geoms
  end

  @impl true
  def default_axes do
    [
      {:x1, %Matplotex.Axis{id: :x1, dimension: :x, position: :bottom, label: "Time"}},
      {:y1, %Matplotex.Axis{id: :y1, dimension: :y, position: :left,   label: "Price"}}
    ]
  end
end
