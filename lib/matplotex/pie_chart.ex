defmodule Matplotex.PieChart do
  @moduledoc """
  Module wraps functions to create a PieChart
  <path d="M 421.51813336588265 240.05640787783966
  A 115 115 0 0 1 332.9904427005054 263.7351087416512
  L 350 150  Z"
  fill="gray"
  stroke="rgba(0,0,0,1)"
  stroke-width="0"
  ></path>
  """


  alias Matplotex.PieChart.Element
  alias Matplotex.PieChart.Legend

  alias Matplotex.PieChart.Slice
  alias Matplotex.PieChart.Content
  alias Content.LegendFrame
  use Matplotex.Blueprint
  @default_size 400
  @width_key "width"
  @height_key "height"
  @label_key "labels"
  @content_params [:color_palette, :legends, :stroke_width]
  @full_circle 2 * :math.pi()
  @label_roatetion_radius_percentage 0.2
  @slice_label_type "label.slice"

  defmodule SliceAcc do
    defstruct [:slices, :datasum, :legend_frame, :x1, :y1, :legends]
  end


  @type word() :: String.t()
  @type params() :: %{
          id: word(),
          title: word(),
          dataset: list(),
          labels: list(),
          color_palette: list(),
          stroke_width: number(),
          width: number(),
          height: number(),
          margin: number(),
          legends: boolean()
        }
  frame()
  @type t() :: frame_struct()
  @impl true
  def new(params) do
    # Fields are dataset, title, size, margin, valid, element, type
    # type: pie chart, dataset from params combination of  data and labels,
    {params, content_params} =
      params
      |> validate_params()
      |> generate_chart_params()
      |> segregate_content(@content_params)

    {struct(__MODULE__, params), content_params}
  end

  @impl true
  @spec set_content({__MODULE__.t(), map()}) ::
          __MODULE__.t()
  def set_content(
        {%__MODULE__{size: %{width: width, height: height}, margin: margin, dataset: dataset} =
           graphset, content_params}
      ) do
    content = struct(%Content{}, content_params)
    c_width = width - margin * 2
    c_height = height - margin * 2
    radius = c_height / 2
    legend_uheight = c_height / length(dataset)
    legend_frame = %LegendFrame{x: c_height + margin, y: margin, uheight: legend_uheight}
    cx = radius + margin
    cy = height - (radius + margin)
    y1 = height - margin

    %__MODULE__{
      graphset
      | content: %Content{
          content
          | width: c_width,
            height: c_height,
            radius: radius,
            cx: cx,
            cy: cy,
            x1: cx,
            y1: y1,
            legend_frame: legend_frame
        }
    }
  end

  @impl true
  def add_elements(graphset) do
    # adding elements means adding slices and legends and labels
    # dataset to its_percentage and slices
    # generate angle
    %__MODULE__.SliceAcc{slices: slices, labels: labels, legends: legends} = generate_slices(graphset)

    %__MODULE__{graphset | element: %Element{slices: slices, labels: labels, legends: legends}}
  end

  @impl true
  def generate_svg(_graphset) do
    # Before generating svg it structs with x1 y1, x2, y2, radius, of the slice
    ""
  end

  defp generate_slices(%__MODULE__{
         dataset: dataset,
         label: label,
         content: %Content{
           radius: radius,
           x1: x1,
           y1: y1,
           color_palette: color_palette,
           legend_frame: legend_frame
         }
       }) do
    # cx and cy are the center
    # will calculate the angle by percentage and take the xn and yn by using R.cos(angle*pie/180) and R.sign(angle*pie/180)
    total = Enum.sum(dataset)

    datacombo = label |> Enum.zip(color_palette) |> Enum.zip(dataset)


    Enum.reduce(
      datacombo,
      %__MODULE__.SliceAcc{
        slices: [],
        labels: [],
        legends: [],
        x1: x1,
        y1: y1,
        datasum: total,
        legend_frame: legend_frame
      },
      fn {data, {label, color}},
         %__MODULE__.SliceAcc{
           slices: slices,
           labels: labels,
           legends: legends,
           x1: x1,
           y1: y1,
           datasum: total,
           legend_frame:
             %LegendFrame{x: legend_x, y: legend_y, uheight: legend_uheight} = legend_frame
         } = acc ->
        angle = data / total * @full_circle
        cos = :math.cos(angle)
        sin = :math.sin(angle)
        x2 = radius * cos
        y2 = radius * sin

        label_rotation_radius = radius * @label_roatetion_radius_percentage
        lx = label_rotation_radius * cos
        ly = label_rotation_radius * sin

        %__MODULE__.SliceAcc{
          acc
          | slices:
              slices ++
                [
                  {%Slice{
                     x1: x1,
                     y1: y1,
                     x2: x2,
                     y2: y2,
                     radius: radius,
                     data: data,
                     color: color
                   }}
                ],
              labels: labels ++ [%Label{x: lx, y: ly, text: label, type: @slice_label_type}],
              legends: legends ++ [%Legend{x: legend_x, y: legend_y, color: color}],

            legend_frame: %LegendFrame{legend_frame | x: legend_x, y: legend_y + legend_uheight}
        }
      end
    )

  end

  defp generate_chart_params({:ok, params}) do
    {width, params} = Map.pop(params, @width_key, @default_size)
    {height, params} = Map.pop(params, @height_key, @default_size)
    {labels, params} = Map.pop(params, @label_key)
    size = %{width: width, height: height}
    params = for {k, v} <- params, into: %{}, do: {String.to_atom(k), v}
    Map.put(params, :size, size)
  end
end
