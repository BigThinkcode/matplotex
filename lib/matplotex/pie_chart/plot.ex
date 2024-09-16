defmodule Matplotex.PieChart.Plot do
  alias Matplotex.PieChart.GenerateSvg
  alias Matplotex.PieChart.Element
  alias Matplotex.PieChart.Legend

  alias Matplotex.PieChart.Slice
  alias Matplotex.PieChart.Content
  alias Content.LegendFrame
  alias Matplotex.PieChart

  use Matplotex.Blueprint
  @default_size 400
  @width_key "width"
  @height_key "height"
  @label_key "labels"
  @content_params [:color_palette, :legends, :stroke_width]
  @full_circle 2 * :math.pi()
  @label_roatetion_radius_percentage 0.2
  @slice_label_type "label.slice"
  @start_angle -:math.pi() / 2

  defmodule SliceAcc do
    defstruct [:slices, :datasum, :legend_frame, :x1, :y1, :legends, :labels, :start_angle]
  end

  @impl true
  @spec new(module(), PieChart.params()) :: {PieChart.t(), map()}
  def new(module, params) do
    # Fields are dataset, title, size, margin, valid, element, type
    # type: pie chart, dataset from params combination of  data and labels,
    {params, content_params} =
      params
      |> validate_params()
      |> generate_chart_params()
      |> segregate_content(@content_params)

    {struct(module, params), content_params}
  end

  @impl true
  @spec set_content({PieChart.t(), map()}) ::
          PieChart.t()
  def set_content(
        {%PieChart{size: %{width: width, height: height}, margin: margin, dataset: dataset} =
           graphset, content_params}
      ) do
    content = struct(%Content{}, content_params)
    c_width = width - margin * 2
    c_height = height - margin * 2
    radius = c_height / 2
    legend_uheight = c_height / length(dataset)
    legend_frame = %LegendFrame{x: c_height + 2 * margin, y: margin, uheight: legend_uheight}
    cx = radius + margin
    cy = height - (radius + margin)
    y1 = margin

    %PieChart{
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
    %__MODULE__.SliceAcc{slices: slices, labels: labels, legends: legends} =
      generate_slices(graphset)

    %PieChart{graphset | element: %Element{slices: slices, labels: labels, legends: legends}}
  end

  @impl true
  def generate_svg(%PieChart{} = chartset) do
    GenerateSvg.generate(chartset, "")
  end

  defp generate_slices(%PieChart{
         dataset: dataset,
         label: label,
         content: %Content{
           radius: radius,
           x1: x1,
           y1: y1,
           cx: cx,
           cy: cy,
           color_palette: color_palette,
           legend_frame: legend_frame,
           labels: labels_turned_on?,
           legends: legends_turned_on?
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
        legend_frame: legend_frame,
        start_angle: @start_angle
      },
      fn {{label, color}, data},
         %__MODULE__.SliceAcc{
           slices: slices,
           labels: labels,
           legends: legends,
           x1: x1,
           y1: y1,
           start_angle: start_angle,
           legend_frame:
             %LegendFrame{x: legend_x, y: legend_y, uheight: legend_uheight} = legend_frame
         } = acc ->
        # TODO - The slices are getting bit moved to some angle at first and the rest is getting right, look like some rotational issues re write the logic with rotating properly
        angle = data / total * @full_circle + start_angle
        cos = :math.cos(angle)
        sin = :math.sin(angle)
        x2 = cx + radius * cos
        y2 = cy + radius * sin

        label_rotation_radius = radius * @label_roatetion_radius_percentage
        # TODO: give clear rotation for labels also
        label_roatation_angle = angle + angle / 2
        lcos = :math.cos(label_roatation_angle)
        lsin = :math.sin(label_roatation_angle)
        lx = cx + label_rotation_radius * lcos
        ly = cy + label_rotation_radius * lsin
        label_rotation_angle_degrees = label_roatation_angle * (180 / :math.pi())

        # rot_max = MathFunc.homogeneous_transformation_matrix(:math.pi()/2 , 0, 0 )

        %__MODULE__.SliceAcc{
          acc
          | slices:
              slices ++
                [
                  %Slice{
                    x1: x1,
                    y1: y1,
                    x2: x2,
                    y2: y2,
                    radius: radius,
                    data: data,
                    color: color,
                    cx: cx,
                    cy: cy
                  }
                ],
            labels:
              add_labels(
                labels,
                {lx, ly, label, data, label_rotation_angle_degrees},
                labels_turned_on?
              ),
            legends:
              add_legends(legends, {legend_x, legend_y, color, label, data}, legends_turned_on?),
            legend_frame: %LegendFrame{legend_frame | x: legend_x, y: legend_y + legend_uheight},
            x1: x2,
            y1: y2,
            start_angle: angle
        }
      end
    )
  end

  defp add_labels(
         labels,
         {lx, ly, label, data, label_rotation_angle_degrees},
         _labels_turned_on = true
       ) do
    labels ++
      [
        %Label{
          x: lx,
          y: ly,
          text: "#{label}-#{data}",
          type: @slice_label_type,
          rotate: label_rotation_angle_degrees
        }
      ]
  end

  defp add_labels(labels, _, _), do: labels

  defp add_legends(legends, {legend_x, legend_y, color, label, data}, _legends_turned_on = true) do
    legends ++ [%Legend{x: legend_x, y: legend_y, color: color, label: "#{label}-#{data}"}]
  end

  defp add_legends(legends, _, _), do: legends

  defp generate_chart_params({:ok, params}) do
    {width, params} = Map.pop(params, @width_key, @default_size)
    {height, params} = Map.pop(params, @height_key, @default_size)
    {labels, params} = Map.pop(params, @label_key)
    size = %{width: width, height: height}
    params = for {k, v} <- params, into: %{}, do: {String.to_atom(k), v}
    Map.merge(params, %{size: size, label: labels})
  end
end
