defmodule Matplotex.Figure.Radial.Pie do
@moduledoc false
  alias Matplotex.Figure.RcParams
  alias Matplotex.Utils.Algebra
  alias Matplotex.Figure.Areal.Region
  alias Matplotex.Figure.Radial
  alias Matplotex.Element.RadLegend
  alias Matplotex.Figure.Radial.LegendAcc
  alias Matplotex.Element.Slice
  alias Matplotex.Figure.Lead
  alias Matplotex.Figure.Radial.Accumulator
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure.TwoD
  alias Matplotex.Figure
  alias Matplotex.Figure.Radial.Dataset
  use Radial

  @full_circle 2 * :math.pi()
  chord(
    center: %TwoD{},
    lead: %TwoD{},
    coords: %Coords{},
    region_title: %Region{},
    region_legend: %Region{},
    region_content: %Region{}
  )

  @impl Radial
  def create(%Figure{axes: axes} = figure, sizes, opts) do
    dataset =
      if sizes |> Enum.sum() |> abs() > 0 do
        Dataset.cast(%Dataset{sizes: sizes}, opts)
      else
        raise Matplotex.InputError,
              "Invalid set of values for a pie chart, sum of sizes should be greater than 0"
      end

    %Figure{figure | axes: %{axes | dataset: dataset}}
  end

  @impl Radial
  def materialize(figure) do
    figure
    |> __MODULE__.materialized()
    |> materialize_slices()
  end

  defp materialize_slices(
         %Figure{
           figsize: {fwidth, fheight},
           rc_params: %RcParams{legend_font: legend_font},
           axes:
             %__MODULE__{
               size: {_width, height},
               radius: radius,
               center: center,
               region_legend: region_legend,
               dataset: %Dataset{
                 sizes: sizes,
                 labels: labels,
                 colors: colors,
                 start_angle: start_angle
               },
               element: elements
             } = axes
         } = figure
       )
       when fwidth > 0 and fheight > 0 do
    %Region{x: legx, y: legy} = Algebra.flip_y_coordinate(region_legend)
    total_size = Enum.sum(sizes)
    legend_rect_side = height / length(sizes) / 2
    center = Algebra.flip_y_coordinate(center)

    slices =
      sizes
      |> Enum.zip(labels)
      |> Enum.zip_reduce(
        colors,
        %Accumulator{
          lead: sector_by_angle(center, start_angle, radius),
          start_angle: start_angle,
          legend_acc: %LegendAcc{
            x: legx,
            y: legy,
            uheight: legend_rect_side,
            uwidth: legend_rect_side
          }
        },
        fn raw, color, acc ->
          roll_across(raw, color, acc, center, radius, total_size, legend_font)
        end
      )
      |> then(fn %Accumulator{slices: slices, legends: legends} ->
        slices ++ legends
      end)

    %Figure{figure | axes: %__MODULE__{axes | element: elements ++ slices}}
  end

  defp sector_by_angle(%{x: cx, y: cy}, angle, radius) do
    cos = :math.cos(angle)
    sin = :math.sin(angle)
    {cx + radius * cos, cy + radius * sin}
  end

  defp roll_across(
         {size, label},
         color,
         %Accumulator{
           lead: {x1, y1},
           slices: slices,
           legends: legends,
           start_angle: start_angle,
           legend_acc:
             %LegendAcc{
               x: x_legend,
               y: y_legend,
               uheight: legend_unit_height,
               uwidth: legend_unit_width
             } = legend_acc
         },
         %{x: cx, y: cy} = center,
         radius,
         total_size,
         legend_font
       ) do
    percentage = size / total_size
    angle_for_size = percentage * @full_circle + start_angle
    {x2, y2} = sector_by_angle(center, angle_for_size, radius)

    slice = %Slice{
      type: "pie.slice",
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      radius: radius,
      data: size,
      percentage: percentage,
      color: color,
      cx: cx,
      cy: cy
    }

    {x_legend, y_legend} =
      Algebra.transform_given_point(0, legend_unit_height, x_legend, y_legend)

    legend =
      %RadLegend{
        type: "pie.legend",
        x: x_legend,
        y: y_legend,
        color: color,
        width: legend_unit_width,
        height: legend_unit_height,
        label: "#{label}-#{Float.ceil(percentage * 100, 2)}%"
      }
      |> RadLegend.with_label(legend_font)

    %Accumulator{
      lead: {x2, y2},
      slices: slices ++ [slice],
      legends: legends ++ [legend],
      start_angle: angle_for_size,
      legend_acc: %LegendAcc{legend_acc | y: y_legend}
    }
  end
end
