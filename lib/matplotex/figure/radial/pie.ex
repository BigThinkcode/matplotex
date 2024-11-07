defmodule Matplotex.Figure.Radial.Pie do
  alias Matplotex.Element.Slice
  alias Matplotex.Figure.Lead
  alias Matplotex.Figure.Radial.Accumulator
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure.TwoD
  alias Matplotex.Figure
  alias Matplotex.Figure.Radial.Dataset
  use Matplotex.Figure.Radial

  @full_circle 2 * :math.pi()
  chord([center: %TwoD{}, lead: %TwoD{}, coords: %Coords{}])
  def create(%Figure{axes: axes}=figure, sizes, opts) do
    dataset = Dataset.cast(%Dataset{sizes: sizes}, opts)
    %Figure{figure | axes: %{axes | dataset: dataset} }
  end

  def materialize(figure) do
    figure
    |>__MODULE__.materialized()
    |>materialize_slices()
  end
  defp materialize_slices(%Figure{axes: %{radius: radius, center: %TwoD{x: cx, y: cy} = center, dataset: %Dataset{sizes: sizes, labels: labels, colors: colors, start_angle: start_angle},element: elements}}) do
    total_size = Enum.sum(sizes)
    sizes
    |>Enum.zip(labels)
    |>Enum.zip_reduce(%Accumulator{lead: sector_by_angle(center, start_angle, radius), start_angle: start_angle},fn raw, acc ->
      roll_across(raw, acc, center, radius, total_size)
    end )


  end

  defp sector_by_angle(%{x: cx, y: cy}, angle, radius) do
    {cx + radius *  :math.cos(angle), cy + radius * :math.sin(angle)}
  end

  defp roll_across({{size, label}, color}, %Accumulator{lead: {x1, y1}, slices: slices, labels: labels, legends: legends, legend: legend, start_angle: start_angle}, %{x: cx, y: cy} =center, radius, total_size) do
    angle_for_size = (size / total_size) * @full_circle + start_angle
    {x2, y2} = sector_by_angle(center, angle_for_size, radius)
    slice = %Slice{x1: x1, y1: y1, x2: x2, y2: y2, radius: radius, data: size, color: color, cx: cx, cy: cy }
  end
end
