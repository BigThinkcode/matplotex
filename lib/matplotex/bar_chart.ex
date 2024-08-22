defmodule Matplotex.BarChart do
  use Matplotex.Blueprint
  alias Matplotex.BarChart.Content
  alias Matplotex.BarChart.Bar
  alias Matplotex.BarChart.Element
  @x_data_range_start_at 0
  @y_data_range_start_at 0
  @default_margin 15
  @default_width 400
  @default_height 400
  @default_ylabel_offset 30
  @default_x_label_offset 20
  @tick_length 5
  @default_color_palette ["#5cf"]

  @type params() :: %{
          dataset: dataset1_d(),
          x_labels: list(),
          color_palette: String.t() | list(),
          width: number(),
          x_margin: number(),
          y_margin: number(),
          height: number(),
          y_scale: number(),
          y_label_sufix: String.t(),
          x_label_offset: number(),
          y_label_offset: number()
        }
  @type t() :: frame_struct()

  frame()
  @impl true
  @spec new(params()) :: {Matplotex.BarChart.t(), map()}
  def new(params) do
    params =
      params
      |> validate_params()
      |> generate_chart_params()

    {params, content_params} = segregate_content(params, [:label_offset, :label_suffix])
    {Map.merge(%__MODULE__{}, params), content_params}
  end

  @spec validate_params(params()) :: {:ok, params()} | {:error, String.t()}
  @impl true
  def validate_params(params) do
    validator()
    |> validate_keys(params)
    |> run_validator(validator(), params)
  end
#TODO - Move this data to validator module
  @impl true
  def validator() do
    %{
      "dataset" => fn dataset -> validate_dataset(dataset) end,
      "x_labels" => fn x_labels -> is_list(x_labels) end,
      "color_palette" => fn color_palette ->
        is_list(color_palette) or is_binary(color_palette)
      end,
      "width" => fn width -> is_number(width) end,
      "height" => fn height -> is_number(height) end,
      "x_margin" => fn x_margin -> is_number(x_margin) end,
      "y_margin" => fn y_margin -> is_number(y_margin) end,
      "y_scale" => fn y_scale -> is_number(y_scale) end,
      "y_label_suffix" => fn yls -> is_binary(yls) end,
      "y_label_offset" => fn ylo -> is_number(ylo) end,
      "x_label_offset" => fn xlo -> is_number(xlo) end
    }
  end

  @impl true
  def set_content(
        {%__MODULE__{
           dataset: %{y: y_dataset},
           size: %{width: width, height: height},
           margin: %{x_margin: x_margin, y_margin: y_margin}
         } = chartset,
         %{
           label_offset: %{x: x_label_offset, y: y_label_offset} = label_offset,
           label_sufix: label_sufix
         }}
      ) do
    dlength =
      y_dataset
      |> List.flatten()
      |> length()

    content_width = width - y_label_offset - 2 * x_margin
    usize = content_width / dlength
    umargin = usize * 0.1
    u_width = usize - umargin

    %{
      chartset
      | content: %Content{
          width: content_width,
          height: height - x_label_offset - 2 * y_margin,
          x: y_margin + y_label_offset,
          y: x_margin + x_label_offset,
          u_margin: umargin,
          u_width: u_width,
          tick_length: @tick_length,
          label_offset: label_offset,
          label_suffix: label_sufix
        }
    }
  end

  @impl true
  def add_elements(chartset) do
    chartset
    |> add_axis_lines()
    |> add_grid_lines()
    |> add_bars_and_labels()
  end

  defp generate_chart_params({:ok, params}) do
    y_data = Map.get(params, "dataset")
    x_data = params |> Map.get("x_labels") |> generate_x_data()
    dataset = %{x: x_data, y: y_data}

    label_offset = label_offset(params)
    {labels, y_max, y_scale, label_sufix} = generate_labels(params, y_data)

    %{
      color_palette: Map.get(params, "color_palette", @default_color_palette),
      dataset: dataset,
      label_offset: label_offset,
      label_suffix: label_sufix,
      label: labels,
      margin: %{
        x_margin: Map.get(params, "x_margin", @default_margin),
        y_margin: Map.get(params, "x_margin", @default_margin)
      },
      size: %{
        width: Map.get(params, "width", @default_width),
        height: Map.get(params, "height", @default_height)
      },
      y_max: y_max,
      scale: %{y: y_scale}
    }
  end

  defp label_offset(params) do
    x_label_offset = Map.get(params, "x_label_offset", @default_x_label_offset)
    y_label_offset = Map.get(params, "y_label_offset", @default_ylabel_offset)
    %{x: x_label_offset, y: y_label_offset}
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
      @y_data_range_start_at..div(y_max, y_scale)
      |> Enum.map(fn value -> "#{value * y_scale}#{y_label_prefix}" end)

    {%{x: Map.get(params, "x_labels"), y: y_labels}, y_max, y_scale, %{x: "", y: y_label_prefix}}
  end

  defp add_axis_lines(
         %__MODULE__{
           content: %Content{x: content_x, height: height},
           size: %{width: width}
         } = chartset
       ) do
    yaxis = %Line{type: "axis.xaxis", x1: content_x, y1: height, x2: content_x, y2: 0}
    y = height

    xaxis = %Line{
      type: "axis.xaxis",
      x1: content_x,
      y1: y,
      x2: width,
      y2: y
    }

    %{chartset | axis_lines: [xaxis, yaxis]}
  end

  defp add_grid_lines(
         %__MODULE__{
           content: %Content{
             height: content_height,
             width: content_width,
             x: cx,
             label_suffix: %{y: y_label_prefix},
             label_offset: %{y: y_label_offset},
             y_max: y_max
           },
           scale: %{y: y_scale},
           dataset: %{y: dataset}
         } = chartset
       ) do
    grids = (y_max / y_scale) |> trunc()

    {grid_lines, {labels, ticks}} =
      1..grids
      |> Enum.map(fn grid ->
        y_scale = grid * y_scale

        {_x, y} =
          transformation(
            0,
            y_scale,
            {0, length(dataset)},
            {0, y_max},
            content_width,
            content_height
          )

        {%Line{type: "grid.xaxis", x1: cx, x2: content_width, y1: y, y2: y},
         {%Label{
            axis: "labels.yaxis",
            x: cx - y_label_offset,
            y: y,
            font_size: "16pt",
            font_weight: "normal",
            text: "#{y_scale}#{y_label_prefix}"
          }, %Line{type: "tick.yaxis", x1: cx, x2: cx - @tick_length, y1: y, y2: y}}}
      end)
      |> Enum.unzip()
      |> then(fn {grid_lines, labels} -> {grid_lines, Enum.unzip(labels)} end)

    %{chartset | element: %Element{ticks: ticks, labels: labels}, grid_lines: grid_lines}
  end

  defp add_bars_and_labels(
         %__MODULE__{
           dataset: %{y: dataset},
           content: %Content{width: width, height: height, y_max: ymax},
           element: %Element{labels: labels, ticks: ticks} = elements
         } = chartset
       ) do
    {bars, {xlabels, xticks}} =
      dataset
      |> Enum.with_index()
      |> transform_dataset(
        width,
        height,
        {0, length(dataset)},
        {0, ymax},
        []
      )
      |> generate_bars(chartset)

    %{
      chartset
      | element: %{elements | bars: bars, labels: labels ++ xlabels, ticks: ticks ++ xticks}
    }
  end

  def transform_dataset([{y, x} | dataset], width, height, xminmax, yminmax, transformed) do
    transforms = transformation(x, y, xminmax, yminmax, width, height)

    transform_dataset(
      dataset,
      width,
      height,
      xminmax,
      yminmax,
      transformed ++ [transforms]
    )
  end

  def transform_dataset([], _width, _height, _xminmax, _yminmax, transformed),
    do: transformed

  defp generate_bars(transformed, %__MODULE__{
         label: %{x: xlabels},
         content:
           %Content{
             height: height,
             u_width: u_width,
             color_palette: color,
             label_offset: %{x: x_label_offset}
           } = content
       }) do
    transformed
    |> Enum.zip(xlabels)
    |> Enum.map(fn {{x, y}, label} ->
      bar_height = Content.bar_height(y, content)

      {%Bar{
         x: Content.transform({:x, x}, content),
         y: y,
         width: u_width,
         height: bar_height,
         color: color
       },
       {%Label{
          axis: "labels.xaxis",
          x: Content.transform({:x, x}, content),
          y: height + x_label_offset,
          font_size: "16pt",
          font_weight: "normal",
          text: label
        },
        %Line{
          x1: Content.x_axis_tick(x, content),
          y1: height,
          x2: Content.x_axis_tick(x, content),
          y2: height + @tick_length,
          type: "tick.xaxis"
        }}}
    end)
    |> Enum.unzip()
    |> then(fn {bars, labels} -> {bars, Enum.unzip(labels)} end)
  end

  defp calculate_y_max(y_max, y_scale) do
    if rem(y_max, y_scale) == 0 do
      y_max
    else
      y_max - rem(y_max, y_scale) + y_scale
    end
  end
  # TODO - move this to validator module
  defp validate_keys(validator, params) do
    params_keys = keys_mapset(params)
    validator_keys = keys_mapset(validator)
    MapSet.subset?(validator_keys, params_keys)
  end

  defp keys_mapset(map) do
    map
    |> Map.keys()
    |> MapSet.new()
  end
end
