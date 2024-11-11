defmodule Matplotex.Figure.Radial.Pie do
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
  chord(center: %TwoD{}, lead: %TwoD{}, coords: %Coords{})
  @impl Radial
  def create(%Figure{axes: axes} = figure, sizes, opts) do
    dataset = Dataset.cast(%Dataset{sizes: sizes}, opts)
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
           figsize: {_fwidth, fheight},
           axes:
             %__MODULE__{
               size: {_width, height},
               radius: radius,
               center: %{y: cy} = center,
               legend_pos: {legx, legy},
               dataset: %Dataset{
                 sizes: sizes,
                 labels: labels,
                 colors: colors,
                 start_angle: start_angle
               },
               element: elements
             } = axes
         } = figure
       ) do
    total_size = Enum.sum(sizes)
    legend_rect_side = height / length(sizes) / 2
    center = %{center | y: fheight - cy}

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
          roll_across(raw, color, acc, center, radius, total_size)
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
         total_size
       ) do
    angle_for_size = size / total_size * @full_circle + start_angle
    {x2, y2} = sector_by_angle(center, angle_for_size, radius)

    slice = %Slice{
      type: "pie.slice",
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      radius: radius,
      data: size,
      color: color,
      cx: cx,
      cy: cy
    }

    y_legend = y_legend - legend_unit_height

    legend =
      %RadLegend{
        type: "pie.legend",
        x: x_legend,
        y: y_legend,
        color: color,
        width: legend_unit_width,
        height: legend_unit_height,
        label: "#{label}-#{size}"
      }
      |> RadLegend.with_label()

    %Accumulator{
      lead: {x2, y2},
      slices: slices ++ [slice],
      legends: legends ++ [legend],
      start_angle: angle_for_size,
      legend_acc: %LegendAcc{legend_acc | y: y_legend}
    }
  end
end
