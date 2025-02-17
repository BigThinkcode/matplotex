defmodule Matplotex.Figure.Areal.BarChart do
  @moduledoc false
  import Matplotex.Figure.Numer
  alias Matplotex.Figure.Areal.PlotOptions
  alias Matplotex.Figure.Areal.Region
  alias Matplotex.Element.Legend
  alias Matplotex.Figure.Dataset
  alias Matplotex.Element.Rect
  alias Matplotex.Figure.RcParams
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure
  alias Matplotex.Figure.Areal
  use Areal

  @xmin_value 0

  frame(
    coords: %Coords{},
    dimension: %Dimension{},
    tick: %TwoD{},
    limit: %TwoD{},
    label: %TwoD{},
    region_x: %Region{},
    region_y: %Region{},
    region_title: %Region{},
    region_legend: %Region{},
    region_content: %Region{}
  )

  @impl Areal
  def create(
        %Figure{axes: %__MODULE__{dataset: data} = axes} = figure,
        {pos, values, width},
        opts
      ) do
    x = hypox(values)
    dataset = Dataset.cast(%Dataset{x: x, y: values, pos: pos, width: width}, opts)
    datasets = data ++ [dataset]
    bottom = Keyword.get(opts, :bottom)
    xydata = datasets |> Enum.reverse() |> flatten_for_data(bottom)

    %Figure{
      figure
      | rc_params: %RcParams{white_space: width, y_padding: 0},
        axes: %{axes | data: xydata, dataset: datasets}
    }
    |> PlotOptions.set_options_in_figure(opts)
  end

  @impl Areal
  def materialize(figure) do
    materialize_bars(figure)
  end

  defp materialize_bars(
         %Figure{
           axes:
             %{
               dataset: data,
               limit: %{x: xlim, y: ylim},
               region_content: %Region{
                 x: x_region_content,
                 y: y_region_content,
                 width: width_region_content,
                 height: height_region_content
               },
               element: elements
             } = axes,
           rc_params: %RcParams{
             x_padding: x_padding,
             white_space: white_space,
             concurrency: concurrency
           }
         } = figure
       ) do
    x_padding_value = width_region_content * x_padding + white_space
    shrinked_width_region_content = width_region_content - x_padding_value * 2

    bar_elements =
      data
      |> Enum.map(fn dataset ->
        dataset
        |> do_transform(
          xlim,
          ylim,
          shrinked_width_region_content,
          height_region_content,
          {x_region_content + x_padding_value, y_region_content}
        )
        |> capture(-y_region_content, concurrency)
      end)
      |> List.flatten()

    elements_with_bar = elements ++ bar_elements

    %Figure{figure | axes: %{axes | element: elements_with_bar}}
  end

  @impl Areal
  def with_legend_handle(
        %Legend{x: x, y: y, color: color, width: width, height: height} = legend,
        _dataset
      ) do
    %Legend{legend | handle: %Rect{x: x, y: y, color: color, width: width, height: height}}
  end

  def generate_ticks([{_l, _v} | _] = data) do
    {data, min_max(data)}
  end

  def generate_ticks(data) do
    max = Enum.max(data)
    step = max |> round_to_best() |> div(5) |> round_to_best()
    {list_of_ticks(data, step), {@xmin_value, max}}
  end

  def generate_ticks(side, {min, max} = lim) do
    step = (max - min) / (side * 2)
    {min..max |> Enum.into([], fn d -> d * round_to_best(step) end), lim}
  end

  def capture(%Dataset{transformed: transformed} = dataset, bly, concurrency) do
    if concurrency do
      process_concurrently(transformed, concurrency, [[], dataset, bly])
    else
      capture(transformed, [], dataset, bly)
    end
  end

  def capture(
        [{{x, y}, bottom} | to_capture],
        captured,
        %Dataset{
          color: color,
          width: width,
          pos: pos_factor,
          edge_color: edge_color,
          alpha: alpha,
          line_width: line_width
        } = dataset,
        bly
      ) do
    capture(
      to_capture,
      captured ++
        [
          %Rect{
            type: "figure.bar",
            x: bar_position(x, pos_factor),
            y: y,
            width: width,
            height: bottom - y,
            color: color,
            stroke: edge_color || color,
            fill_opacity: alpha,
            stroke_opacity: alpha,
            stroke_width: line_width
          }
        ],
      dataset,
      bly
    )
  end

  def capture(
        [{x, y} | to_capture],
        captured,
        %Dataset{
          color: color,
          width: width,
          pos: pos_factor,
          edge_color: edge_color,
          alpha: alpha,
          line_width: line_width
        } = dataset,
        bly
      ) do
    capture(
      to_capture,
      captured ++
        [
          %Rect{
            type: "figure.bar",
            x: bar_position(x, pos_factor),
            y: y,
            width: width,
            height: bly - y,
            color: color,
            stroke: edge_color || color,
            fill_opacity: alpha,
            stroke_opacity: alpha,
            stroke_width: line_width
          }
        ],
      dataset,
      bly
    )
  end

  def capture([], captured, _dataset, _bly), do: captured

  defp hypox(y) do
    nof_x = length(y)
    @xmin_value |> Nx.linspace(nof_x, n: nof_x) |> Nx.to_list()
  end

  defp bar_position(x, pos_factor) do
    x + pos_factor
  end

  defp list_of_ticks(data, step) do
    1..length(data)
    |> Enum.into([], fn d ->
      d * step
    end)
  end
end
