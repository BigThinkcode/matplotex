defmodule Matplotex.Figure.Areal.BarChart do
  import Matplotex.Figure.Numer
  alias Matplotex.Figure.Areal.Region
  alias Matplotex.Figure.Dataset
  alias Matplotex.Element.Rect
  alias Matplotex.Figure.RcParams
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure
  alias Matplotex.Figure.Areal
  use Areal

  @xmin_value 0

  frame(
    legend: %Legend{},
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
    xydata = flatten_for_data(datasets)

    %Figure{
      figure
      | rc_params: %RcParams{white_space: width, y_padding: 0},
        axes: %{axes | data: xydata, dataset: datasets}
    }
  end

  @impl Areal
  def materialize(figure) do
    __MODULE__.materialized_by_region(figure)
    |> materialize_bars()
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
           rc_params: %RcParams{x_padding: x_padding, white_space: white_space}
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
        |> capture(-y_region_content)
      end)
      |> List.flatten()

    elements_with_bar = elements ++ bar_elements

    %Figure{figure | axes: %{axes | element: elements_with_bar}}
  end

  @impl Areal
  def plotify(value, {minl, maxl}, axis_size, transition, _data, :x) do
    s = axis_size / (maxl - minl)
    value * s + transition - minl * s
  end

  def plotify(value, {minl, maxl}, axis_size, transition, _data, :y) do
    s = axis_size / (maxl - minl)
    value * s + transition - minl * s
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

  defp capture(%Dataset{transformed: transformed} = dataset, bly) do
    capture(transformed, [], dataset, bly)
  end

  defp capture(
         [{x, y} | to_capture],
         captured,
         %Dataset{
           color: color,
           width: width,
           pos: pos_factor
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
            color: color
          }
        ],
      dataset,
      bly
    )
  end

  defp capture([], captured, _dataset, _bly), do: captured

  defp hypox(y) do
    nof_x = length(y)
    @xmin_value |> Nx.linspace(nof_x, n: nof_x) |> Nx.to_list()
  end

  defp bar_position(x, pos_factor) when pos_factor < 0 do
    x + pos_factor
  end

  defp bar_position(x, _pos_factor), do: x

  defp list_of_ticks(data, step) do
    1..length(data)
    |> Enum.into([], fn d ->
      d * step
    end)
  end
end
