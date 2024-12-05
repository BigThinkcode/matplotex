defmodule Matplotex.Figure.Areal.LinePlot do
  alias Matplotex.Utils.Algebra
  alias Matplotex.Figure.Areal.Region
  alias Matplotex.Figure.Areal.Ticker
  alias Matplotex.Figure.Marker
  alias Matplotex.Figure.Dataset
  alias Matplotex.Figure.Areal
  alias Matplotex.Figure.RcParams
  alias Matplotex.Element.Line
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure

  use Matplotex.Figure.Areal

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

  @marker_size 3.5
  @impl Areal
  def create(
        %Figure{axes: %__MODULE__{dataset: data} = axes} = figure,
        {x, y},
        opts \\ []
      ) do
    x = determine_numeric_value(x)
    y = determine_numeric_value(y)
    dataset = Dataset.cast(%Dataset{x: x, y: y}, opts)
    datasets = data ++ [dataset]
    xydata = flatten_for_data(datasets)
    %Figure{figure | axes: %{axes | data: xydata, dataset: datasets}}
  end

  @impl Areal
  def materialize(figure) do
    figure
    |> __MODULE__.materialized_by_region()
    |> materialize_lines()
  end

  defp materialize_lines(
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
           rc_params: %RcParams{x_padding: x_padding, y_padding: y_padding}
         } = figure
       ) do
    # {x_region_content, y_region_content} = Algebra.flip_y_coordinate({x_region_content, y_region_content})
    x_padding_value = width_region_content * x_padding
    y_padding_value = height_region_content * y_padding
    shrinked_width_region_content = width_region_content - x_padding_value * 2
    shrinked_height_region_content = height_region_content - y_padding_value * 2

    IO.inspect({shrinked_height_region_content, shrinked_height_region_content, y_region_content},
      label: "Shrinked size"
    )

    line_elements =
      data
      |> Enum.map(fn dataset ->
        dataset
        |> do_transform(
          xlim,
          ylim,
          shrinked_width_region_content,
          shrinked_height_region_content,
          {x_region_content + x_padding_value, y_region_content + y_padding_value}
        )
        |> capture()
      end)
      |> List.flatten()

    elements = elements ++ line_elements
    %Figure{figure | axes: %{axes | element: elements}}
  end

  @impl Areal
  def plotify(value, {minl, maxl}, axis_size, transition, _, _) do
    s = axis_size / (maxl - minl)
    value * s + transition - minl * s
  end

  def tick_homogeneous_transformation(value, {x_min, x_max}, axis_size, transition, :x) do
    sx = axis_size / (x_max - x_min)
    # no need y scale
    sy = 0
    x = value
    # Ignoring y here
    y = 0
    tx = transition
    ty = 0
    # not applying rotation
    theta = 0
    Algebra.transform_given_point(x, y, sx, sy, tx, ty, theta)
  end

  def tick_homogeneous_transformation(value, {y_min, y_max}, axis_size, transition, :y) do
    sx = 0
    sy = axis_size / (y_max - y_min)
    x = 0
    y = value
    tx = 0
    ty = transition
    # not applying rotation
    theta = 0
    Algebra.transform_given_point(x, y, sx, sy, tx, ty, theta)
  end

  def generate_ticks([{_l, _v} | _] = data) do
    {data, min_max(data)}
  end

  def generate_ticks(data) when is_list(data) do
    lim = Enum.min_max(data)

    {Ticker.generate_ticks(lim), lim}
  end

  def generate_ticks({_min, _max} = lim) do
    {Ticker.generate_ticks(lim), lim}
  end

  defp capture(%Dataset{transformed: transformed} = dataset) do
    capture(transformed, [], dataset)
  end

  defp capture(
         [{x1, y1} | [{x2, y2} | _] = to_capture],
         captured,
         %Dataset{
           color: color,
           marker: marker,
           linestyle: linestyle
         } = dataset
       ) do
    capture(
      to_capture,
      captured ++
        [
          %Line{
            type: "plot.line",
            x1: x1,
            y1: y1,
            x2: x2,
            y2: y2,
            stroke: color,
            fill: color,
            linestyle: linestyle
          },
          Marker.generate_marker(marker, x1, y1, color, @marker_size)
        ],
      dataset
    )
  end

  defp capture([{x, y}], captured, %Dataset{color: color, marker: marker}) do
    captured ++ [Marker.generate_marker(marker, x, y, color, @marker_size)]
  end
end
