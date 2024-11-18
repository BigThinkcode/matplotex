defmodule Matplotex.Figure.Areal.Scatter do
  import Matplotex.Figure.Numer
  alias Matplotex.Figure.Sketch
  alias Matplotex.Figure.Shoot
  alias Matplotex.Figure.Marker
  alias Matplotex.Figure.Dataset

  alias Matplotex.Figure.Areal
  alias Matplotex.Figure.RcParams

  alias Matplotex.Figure.Coords
  alias Matplotex.Figure

  @default_number_of_ticks 5

  use Areal

  frame(
    legend: %Legend{},
    coords: %Coords{},
    dimension: %Dimension{},
    tick: %TwoD{},
    limit: %TwoD{},
    label: %TwoD{}
  )

  @impl Areal
  def create(%Figure{axes: %__MODULE__{dataset: data} = axes} = figure, {x, y}, opts ) do
    x = determine_numeric_value(x)
    y = determine_numeric_value(y)
    dataset = Dataset.cast(%Dataset{x: x, y: y}, opts)
    datasets = data ++ [dataset]
    xydata = flatten_for_data(datasets)
    %Figure{figure | axes: %{axes | data: xydata, dataset: datasets}}
  end

  def create(stream, {width, height}, opts ) when is_struct(stream, Stream) do
    opts = Enum.into(opts, %{})
    {xlim, ylim} =  maybe_generate_minmax(stream, opts)

    xticks =  maybe_generate_xticks(xlim, opts)
    yticks =  maybe_generate_yticks(xlim, opts)

    xlabel = Map.get(opts, :xlabel)
    ylabel = Map.get(opts, :ylabel)
    title = Map.get(opts, :title)
   {stream, %Figure{
    figsize: {width, height},
    axes: %__MODULE__{
      limit: %TwoD{x: xlim, y: ylim},
      label: %TwoD{x: xlabel, y: ylabel},
      tick: %TwoD{x: xticks, y: yticks},
      title: title,
      data: {[],[]},
      dataset: []
     }
   }}
  end

  @impl Areal

  def materialize({xystream, figure}) do
    figure
    |>__MODULE__.materialized()
    |> material_stream(xystream)
  end
  def materialize(figure) do
    __MODULE__.materialized(figure)
    |> materialize_elements()
  end


  defp materialize_elements(
         %Figure{
           axes:
             %{
               dataset: data,
               limit: %{x: xlim, y: ylim},
               size: {width, height},
               coords: %Coords{bottom_left: {blx, bly}},
               element: elements
             } = axes,
           rc_params: %RcParams{x_padding: x_padding, y_padding: y_padding}
         } = figure
       ) do
    px = width * x_padding
    py = height * y_padding
    width = width - px * 2
    height = height - py * 2

    line_elements =
      data
      |> Enum.map(fn dataset ->
        dataset
        |> do_transform(xlim, ylim, width, height, {blx + px, bly + py})
        |> capture()
      end)
      |> List.flatten()

    elements = elements ++ line_elements
    %Figure{figure | axes: %{axes | element: elements}}
  end



  def material_stream(
        %Figure{
          figsize: {fwidth, fheight},
          axes: %__MODULE__{
            limit: %TwoD{x: xlim, y: ylim},
            element: element,
            coords: %Coords{bottom_left: {blx, bly}},
            size: {width, height}
          }
        } = figure,
        xystream
      ) do

      header = Sketch.header(fwidth * 96, fheight * 96)
      canvas = Enum.reduce(element, header, fn %module{} = elem, acc ->
        elem = module.flipy(elem, fheight)
        strelem = module.assemble(elem)
        acc <> strelem
      end)
    # {
    # sch = :erlang.system_info(:schedulers)
      Stream.map(xystream, fn {x, y} ->
       {matx, maty} = transformation(x, y, xlim, ylim, width, height, {blx, bly})
      elem = %module{}= Marker.generate_marker("o", matx, maty, "blue", 5)
      elem = module.flipy(elem, fheight)
      module.assemble(elem)
     end
    #  , max_concurrency: sch
    )
     |>Enum.reduce(canvas, fn elem, acc ->
      acc <> elem
     end)
    #  |> Stream.concat(element),
      # figure}
  end

  defp capture(%Dataset{transformed: transformed} = dataset) do
    capture(transformed, [], dataset)
  end

  defp capture(
         [{x, y} | to_capture],
         captured,
         %Dataset{
           color: color,
           marker: marker,
           marker_size: marker_size
         } = dataset
       ) do
    capture(
      to_capture,
      captured ++
        [
          Marker.generate_marker(marker, x, y, color, marker_size)
        ],
      dataset
    )
  end

  defp capture(_, captured, _), do: captured
  @impl Areal
  def plotify(value, {minl, maxl}, axis_size, transition, _, _) do
    s = axis_size / (maxl - minl)
    value * s + transition - minl * s
  end

  def generate_ticks([{_l, _v} | _] = data) do
    {data, min_max(data)}
  end

  def generate_ticks(data) when is_list(data) do
    {min, max} = lim = Enum.min_max(data)
    step = (max - min) / @default_number_of_ticks
    {min..max |> Enum.into([], fn d -> d * round(step) end), lim}
  end
  def generate_ticks({min, max}) do
    step = (max - min) / @default_number_of_ticks

    Range.new(round(min), round(max), round(step))|>Enum.into([])

  end

  defp maybe_generate_minmax(_stream, %{xlim: xlim, ylim: ylim}) do
    {xlim, ylim}
  end
  defp maybe_generate_minmax(stream, _) do
    {{xmin, _}, {xmax, _}} = Enum.min_max_by(stream, &elem(&1, 0))
    {{_xmin, ymin}, {_xmax, ymax}} = Enum.min_max_by(stream, &elem(&1,1))
    {{xmin, xmax}, {ymin, ymax}}
  end

  defp maybe_generate_xticks(_xlim, %{xticks: xticks}), do: xticks

  defp maybe_generate_xticks(xlim, _), do: generate_ticks(xlim)

  defp maybe_generate_yticks(_ylim, %{yticks: yticks}), do: yticks
  defp maybe_generate_yticks(ylim, _), do: generate_ticks(ylim)

end
