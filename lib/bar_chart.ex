defmodule Matplotex.BarChart do
  @moduledoc """
  This module contains the datastructure and functions to build a barchart
  """

  alias Matplotex.BarChart.Label
  alias Matplotex.BarChart.Bar

  @default_width 700
  @default_height 300
  @default_bars 1
  @default_color ["#131842"]
  defstruct [:content, :width, :height, :bars, :color_palette, :valid?, :errors, :title, :sub_title, :x_labels, :y_labels, :bar_width, :bgap, :cgap, :scale_max, :scale_min, :data_length ]

  def new(data, opts \\ []) do
    %__MODULE__{}
    |>change_data(data, opts)
    |>validate_content()
    # |>create_svg()
  end
  defp change_data(bar_chart, data, opts) do
    width = Keyword.get(opts, :width,@default_width)
    height = Keyword.get(opts, :height, @default_height)
    bars = Keyword.get(opts, :bars, @default_bars)
    color_pallete =  Keyword.get(opts,:color_palette, @default_color )
    bar_chart
    |>Map.put(:content, data)
    |>Map.put(:width, width)
    |>Map.put(:height, height)
    |>Map.put(:bars, bars)
    |>Map.put(:color_palette, color_pallete)

  end
  defp validate_content(%__MODULE__{content: content} = bar_chart) do
    content
    |>Map.values()
    |>Enum.map(fn value -> validate_value(bar_chart,value) end)
  end

  defp validate_value(bar_chart, [value|values]) when is_list(value) do
   bar_chart = validate_value(bar_chart,value)
   validate_value(bar_chart, values)
  end
  defp validate_value(bar_chart, [])  do
    bar_chart
   end
  defp validate_value(bar_chart, value) when is_integer(value) do
    bar_chart
  end

  defp validate_value(bar_chart, value) do
    bar_chart
    |>Map.put(:valid, false)
    |>Map.put(:errors, ["The value #{value} is invalid to generate a chart"])
  end

  def generate_svg(assigns) do
    assigns =
      assigns
      |>Keyword.put(:title, "Monthly sales figures")
      |>Keyword.put(:sub_title, "Turnover grouped by sales team")
      |>Keyword.put(:bars, bars())
      |>Keyword.put(:labels, labels())
    EEx.eval_file(File.cwd!() <> "/lib/bar_chart/bar_chart.eex", assigns)
  end

  defp bars() do
    [
      %Bar{x: 44, y: 155, width: 17.5, height: 110, color: "#5cf"},
      %Bar{x: 63.5, y: 199, width: 17.5, height: 66, color: "black"},
      %Bar{x: 99, y: 177, width: 17.5, height: 88, color: "#5cf"},
      %Bar{x: 118.5, y: 133, width: 17.5, height: 132, color: "black"},
      %Bar{x: 154, y: 166, width: 17.5, height: 99, color: "#5cf"},
      %Bar{x: 173.5, y: 121, width: 17.5, height: 144, color: "black"},
      %Bar{x: 209, y: 156, width: 17.5, height: 109, color: "#5cf"},
      %Bar{x: 228.5, y: 151, width: 17.5, height: 114, color: "black"},
    ]
  end
  defp labels() do
    [
      %Label{axis: "labels.xaxis",x: 62.5,y: 278, font_size: "16pt", font_weight: "normal", text: "Jan"},
      %Label{axis: "labels.xaxis",x: 117,y: 278, font_size: "16pt", font_weight: "normal", text: "Feb"},
      %Label{axis: "labels.xaxis",x: 172,y: 278, font_size: "16pt", font_weight: "normal", text: "March"},
      %Label{axis: "labels.xaxis",x: 227,y: 278, font_size: "16pt", font_weight: "normal", text: "April"},
      %Label{axis: "labels.yaxis",x: 28,y: 221, font_size: "16pt", font_weight: "normal", text: "2k"},
      %Label{axis: "labels.yaxis",x: 28,y: 268, font_size: "16pt", font_weight: "normal", text: "0k"},
      %Label{axis: "labels.yaxis",x: 28,y: 174, font_size: "16pt", font_weight: "normal", text: "4k"},
      %Label{axis: "labels.yaxis",x: 28,y: 127, font_size: "16pt", font_weight: "normal", text: "6k"},
      %Label{axis: "labels.yaxis",x: 28,y: 80, font_size: "16pt", font_weight: "normal", text: "8k"},
      %Label{axis: "labels.yaxis",x: 28,y: 33, font_size: "16pt", font_weight: "normal", text: "10k"},

    ]
  end
  # defp create_svg(bar_chart) do
  #   ~s|<svg> <svg width="700" height="300" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" style="top: 0px; left: 0px; position: absolute;">
  #   <g class="all-elements all-elements-bar all-elements-chart-container all-elements-c523be71-01f4-467e-9d2e-7c3fc25a4abd">
  #    </g>
  #    </svg>|
  # end

  # defp linex(bar_chart) do
  #   ~s|
  #   <path class="rgraph_background_grid" d="M35 45 L695 45 M35 89 L695 89 M35 133 L695 133 M35 177 L695 177 M35 221 L695 221
  #    M35 265 L695 265 M35 265 L695 265" stroke="#ddd" fill="rgba(0,0,0,0)" stroke-width="1" shape-rendering="crispEdges" stroke-dasharray="" style="pointer-events: none;">
  #    </path>
  #   |
  # end

  # defp title(bar_chart) do
  #   ~s|
  #   <text tag="title" data-tag="title" fill="black" x="365" y="19" font-size="16pt" font-weight="bold" font-family="Arial, Verdana, sans-serif" font-style="normal" text-anchor="middle" dominant-baseline="bottom" text-decoration="none" style="pointer-events: none;">Monthly sales figures</text>
  #   |
  # end

  # defp sub_title(bar_chart) do
  #   ~s|
  #   <text tag="subtitle" data-tag="subtitle" fill="#aaa" x="365" y="24" font-size="14pt" font-weight="normal" font-family="Arial, Verdana, sans-serif" font-style="normal" text-anchor="middle" dominant-baseline="hanging" text-decoration="none" style="pointer-events: none;">Turnover grouped by sales team</text>
  #   |
  # end

  # defp bar(bar_chart) do
  #   ~s| <rect stroke="rgba(0,0,0,0)" fill="#5cf" x="44" y="155" width="17.5" height="110" stroke-width="1"  filter="">|
  # end

  # defp axial(bar_chart) do
  #   ~s|
  #    <path d="M35 265 L695 265" fill="black" stroke="black" stroke-width="3" shape-rendering="crispEdges" stroke-linecap="square"></path><text tag="labels.xaxis" data-tag="labels.xaxis" fill="black" x="62.5" y="278" font-size="16pt" font-weight="normal" font-family="Arial, Verdana, sans-serif" font-style="normal" text-anchor="middle" dominant-baseline="hanging" text-decoration="none" style="pointer-events: none;">Jan</text>
  #   |
  # end

  # defp ylabel(bar_chart) do
  #   ~s|<text tag="labels.yaxis" data-tag="labels.yaxis" fill="black" x="28" y="221" font-size="16pt" font-weight="normal" font-family="Arial, Verdana, sans-serif" font-style="normal" text-anchor="end" dominant-baseline="middle" text-decoration="none" style="pointer-events: none;">2k</text>|
  # end
  # defp xlabel(bar_chart) do
  #   ~s|<text tag="labels.xaxis" data-tag="labels.xaxis" fill="black" x="62.5" y="278" font-size="16pt" font-weight="normal" font-family="Arial, Verdana, sans-serif" font-style="normal" text-anchor="middle" dominant-baseline="hanging" text-decoration="none" style="pointer-events: none;">Jan</text>|
  # end
end
