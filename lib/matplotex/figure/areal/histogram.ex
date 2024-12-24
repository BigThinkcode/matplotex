defmodule Matplotex.Figure.Areal.Histogram do
  alias Matplotex.Element.Rect
  alias Matplotex.Figure.RcParams
  alias Matplotex.Figure.Areal.PlotOptions
  alias Matplotex.Figure.Dataset
  alias Matplotex.Figure.Areal.Region
  alias Matplotex.Figure
  alias Matplotex.Figure.Areal
  use Areal

  frame(
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
  def create(%Figure{axes: %__MODULE__{} = axes} = figure, {data, bins}, opts) do
    {x, y} = bins_and_hists(data, bins)

    dataset = Dataset.cast(%Dataset{x: x, y: y}, opts)

    %Figure{figure | axes: %__MODULE__{axes | data: {x, y}, dataset: [dataset]}}
    |> PlotOptions.set_options_in_figure(opts)
  end

  @impl Areal
  def materialize(figure) do
    figure
    |> sanitize()
    |> __MODULE__.materialized_by_region()
    |> materialize_hist()
  end

  defp materialize_hist(%Figure{axes: %{dataset: data,limit: %TwoD{x: x_lim, y: y_lim}, region_content: %Region{x: x_region_content, y: y_region_content, width: width_region_content, height: height_region_content}, element: element}, rc_params: %RcParams{x_padding: x_padding, white_space: white_space}}) do
    x_padding_value = width_region_content * x_padding + white_space
    shrinked_width_region_content = width_region_content - x_padding_value * 2

    hist_elements =
     data
     |>Enum.map(fn dataset ->
      dataset
      |> do_transform(x_lim, y_lim, shrinked_width_region_content, height_region_content, {x_region_content + x_padding_value, y_region_content})
      |> capture(abs(y_region_content), shrinked_width_region_content)
     end)
     |>List.flatten()
    %Figure{axes: %{element: element ++ hist_elements}}
  end

  defp capture(%Dataset{transformed: transformed} = dataset, bly, region_width) do
    capture(transformed, [], dataset, bly, region_width)
  end

  defp capture(
         [{x, y} | to_capture],
         captured,
         %Dataset{
           color: color,
           x: bins,
           pos: pos_factor,
           edge_color: edge_color,
           alpha: alpha
         } = dataset,
         bly,
         region_width
       ) do
    capture(
      to_capture,
      captured ++
        [
          %Rect{
            type: "figure.histogram",
            x: bin_position(x, pos_factor),
            y: y,
            width: region_width / length(bins),
            height: bly - y,
            color: color,
            stroke: edge_color,
            fill_opacity: alpha,
            stroke_opacity: alpha
          }
        ],
      dataset,
      bly,
      region_width
    )
  end

  defp capture([], captured, _dataset, _bly, _region_width), do: captured


  defp bin_position(x, pos_factor) when pos_factor < 0 do
    x + pos_factor
  end

  defp bin_position(x, _pos_factor), do: x
  defp bins_and_hists(data, bins) do
    {data_min, data_max} = Enum.min_max(data)

    bins_dist =
      data_min
      |> Nx.linspace(data_max, n: bins)
      |> Nx.to_list()

    {hists, _} =
      Enum.map_reduce(bins_dist, data_min, fn bin, previous_bin ->
        frequency = Enum.frequencies_by(data, fn point -> point < bin && point > previous_bin end)
        {Map.get(frequency, true, 0), bin}
      end)

    {bins_dist, hists}
  end

  defp sanitize(%Figure{axes: %__MODULE__{data: {x, y}}= axes} = figure) do
    {ymin, ymax} = Enum.min_max(y)
    {xmin, xmax} = Enum.min_max(x)
    {xmin, xmax} = {floor(xmin), ceil(xmax)}

    %Figure{figure | axes: %__MODULE__{axes | limit: %TwoD{y: {floor(ymin), ceil(ymax)}, x: xlim }}}
   end
end
