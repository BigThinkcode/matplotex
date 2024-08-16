defmodule Matplotex.Draw.BarChart do
  alias Matplotex.Blueprint.Areal
  alias Matplotex.Blueprint.Areal.Chart
  use Matplotex.Blueprint.Areal

  @x_data_range_start_at 0

  @type params() :: %{
          dataset: list(),
          x_labels: list(),
          color_palette: String.t() | list(),
          width: number(),
          margin: number(),
          height: number(),
          y_scale: number(),
          y_label_prefix: String.t(),
          y_label_offset: number(),
          x_label_offset: number()
        }

  @doc """
  New accepts a set of params and creates a chart data

  %{
      "dataset" => [44, 56, 67, 67, 89, 14, 57, 33, 59, 67, 90, 34],
      "x_labels" => ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
      "color_palette" =>  "#5cf",
      "width" => 700,
      "margin" => 15,
      "height" => 300,
      "y_scale" => 20,
      "y_label_prefix" => "K",
      "y_label_offset" => 40,
      "x_label_offset" => 20
    }

  """
  @impl Areal
  def new(params) do
    params
    |> generate_chart_params()
    |> Chart.new()
  end

  @impl Areal
  def set_content(chartset) do
  end

  defp generate_chart_params(params) do
    y_data = Map.get(params, "dataset")
    x_data = params |> Map.get("x_labels") |> generate_x_data()
    dataset = %{x: x_data, y: y_data}

    label_offset = label_offset(params)
    {labels, y_max, y_scale, label_prefix} = generate_labels(params, y_data)

    %{
      color_palette: Map.get(params, "color_palette"),
      dataset: dataset,
      height: Map.get(params, "height"),
      label_offset: label_offset,
      label_prefix: label_prefix,
      labels: labels,
      margin: Map.get(params, "margin"),
      type: __MODULE__,
      width: Map.get(params, "width"),
      y_max: y_max,
      y_scale: y_scale
    }
  end

  defp generate_x_data([x_label | _] = x_labels) when is_number(x_label), do: x_labels

  defp generate_x_data([x_label | _] = x_labels) when is_binary(x_label) do
    @x_data_range_start_at
    |> Range.new(length(x_labels))
    |> Range.to_list()
  end

  defp generate_labels(params, y_data) do
    y_label_prefix = Map.get(params, "y_label_prefix")

    y_scale = Map.get(params, "y_scale")
    y_max = Enum.max(y_data)
    y_max = calculate_y_max(y_max, y_scale)

    y_labels =
      0..div(y_max, y_scale) |> Enum.map(fn value -> "#{value * y_scale}#{y_label_prefix}" end)

    {%{x: Map.get(params, "x_labels"), y: y_labels}, y_max, y_scale, %{x: "", y: y_label_prefix}}
  end

  defp calculate_y_max(y_max, y_scale) do
    if rem(y_max, y_scale) == 0 do
      y_max
    else
      y_max - rem(y_max, y_scale) + y_scale
    end
  end

  defp label_offset(params) do
    x_label_offset = Map.get(params, "x_label_offset")
    y_label_offset = Map.get(params, "y_label_offset")
    %{x: x_label_offset, y: y_label_offset}
  end
end
