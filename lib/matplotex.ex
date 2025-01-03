defmodule Matplotex do
  @moduledoc """
  Module to generate a graph.
  """
  alias Matplotex.Figure.Areal.Spline
  alias Matplotex.Figure.Areal.Histogram
  alias Matplotex.InputError
  alias Matplotex.Figure.Radial.Pie
  alias Matplotex.Figure.Areal.Scatter
  alias Matplotex.Figure.Areal.LinePlot
  alias Matplotex.Figure.Sketch
  alias Matplotex.Figure
  alias Matplotex.Figure.Areal.BarChart

  def bar(values, width) do
    bar(width, values, width, [])
  end

  def bar(values, width, opts) when is_list(opts) do
    bar(width, values, width, opts)
  end

  def bar(pos, values, width) do
    bar(pos, values, width, [])
  end

  def bar(pos, values, width, opts) do
    BarChart.create(%Figure{axes: %BarChart{}}, {pos, values, width}, opts)
  end

  def bar(%Figure{} = figure, pos, values, width, opts) do
    figure
    |> show_legend()
    |> BarChart.create({pos, values, width}, opts)
  end

  @doc """
  Creates a scatter plot based on the given data
  """
  def scatter(stream, opts) when is_struct(stream, Stream) do
    Scatter.create(stream, opts)
  end

  def scatter(x, y) do
    scatter(x, y, [])
  end

  def scatter(x, y, opts) do
    Scatter.create(%Figure{axes: %Scatter{}}, {x, y}, opts)
  end

  def scatter(%Figure{} = figure, x, y, opts) do
    figure
    |> show_legend()
    |> Scatter.create({x, y}, opts)
  end

  @doc """
  Creates a piec charts based on the size and opts
  """
  def pie(sizes, opts \\ []) do
    Pie.create(%Figure{axes: %Pie{}}, sizes, opts)
  end

  @doc """
  Creates a line plot with given x and y data.

  ## Examples

      iex> Matplotex.plot([1, 2, 3], [4, 5, 6])
      %Matplotex.Figure{}

  """

  @spec plot(list(), list()) :: Figure.t()
  def plot(x, y) when is_list(x) and is_list(y) do
    plot(x, y, [])
  end

  def plot(_x, _y) do
    raise InputError, "Invalid x and y values for plot, x and y should be in list"
  end

  def plot(x, y, opts) do
    LinePlot.create(%Figure{axes: %LinePlot{}}, {x, y}, opts)
  end

  def plot(%Figure{} = figure, x, y, opts) do
    figure
    |> show_legend()
    |> LinePlot.create({x, y}, opts)
  end

  @doc """
   Creates a histogram with given data and bins.

   ## Examples

       iex> Matplotex.hist([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 5)
  """
  def hist(data, bins), do: hist(data, bins, [])

  def hist(data, bins, opts) do
    Histogram.create(%Figure{axes: %Histogram{}}, {data, bins}, opts)
  end

  def spline(x, y), do: spline(x, y, [])
  def spline(x, y, opts), do: spline(%Figure{axes: %Spline{}}, x, y, opts)

  def spline(%Figure{} = figure, x, y, opts) do
    Spline.create(figure, {x, y}, opts)
  end

  @doc """
  Sets X and Y labels for the graph with given font details

  ## Examples

      iex> Matplotex.set_xlabel(figure,"X label", font_family: "Ariel", font_size: 16, color: "red" )
      %Matplotex.Figure{}

  """

  @spec set_xlabel(Figure.t(), String.t()) :: Figure.t()
  def set_xlabel(figure, label, opts \\ []) do
    Figure.add_label(figure, {:x, label}, opts)
  end

  @doc """
  Sets Y label for the graph with given font details

  ## Examples

      iex> Matplotex.set_ylabel(figure, "Y label", [font_family: "Ariel", font_size: 16, color: "green"])
      %Matplotex.Figure{}
  """

  @spec set_ylabel(Figure.t(), String.t()) :: Figure.t()
  def set_ylabel(figure, label, opts \\ []) do
    Figure.add_label(figure, {:y, label}, opts)
  end

  @doc """
  Sets Title for the graph with given font details

  ## Examples

      iex> Matplotex.plot(x,y)
           |> Matplotex.set_title("My Graph", font_family: "Arial", font_size: 20, color: "red")
      %Matplotex.Figure{}

  """

  @spec set_title(Figure.t(), String.t()) :: Figure.t()
  def set_title(figure, title, opts \\ []) do
    Figure.add_title(figure, title, opts)
  end

  @doc """
  Sets X tick labels for the graph with given font details

  ## Examples

      iex> Matplotex.set_xticks(figure, [1, 2, 3,4,5,6,7,8])
      %Matplotex.Figure{}

  """
  @spec set_xticks(Figure.t(), list()) :: Figure.t()
  def set_xticks(figure, ticks) when is_list(ticks) do
    Figure.add_ticks(figure, {:x, ticks})
  end

  def set_xticks(figure, {_min, _max} = lim) do
    Figure.add_ticks(figure, {:x, lim})
  end

  # TODO: Set x and y ticks with value and label for string inputs

  @doc """
  Sets Y tick labels for the graph with given details
  ## Examples

      iex> Matplotex.set_yticks(figure, [10, 20, 30, 40, 50])
      %Matplotex.Figure{}
  """

  @spec set_yticks(Figure.t(), list()) :: Figure.t()
  def set_yticks(figure, ticks) when is_list(ticks) do
    Figure.add_ticks(figure, {:y, ticks})
  end

  def set_yticks(figure, {_min, _max} = lim) do
    Figure.add_ticks(figure, {:y, lim})
  end

  @doc """
  Sets X and Y limits for the graph with given details

  ## Examples

      iex> Matplotex.set_xlim(figure, {1,10})
      %Matplotex.Figure{}

  """
  @spec set_xlim(Figure.t(), tuple()) :: Figure.t()
  def set_xlim(figure, xlim) do
    Figure.set_limit(figure, {:x, xlim})
  end

  @doc """
  Sets Y limit for the graph with given details

  ## Examples

      iex> Matplotex.set_ylim(figure, {10,50})
      %Matplotex.Figure{}
  """

  @spec set_ylim(Figure.t(), tuple()) :: Figure.t()
  def set_ylim(figure, ylim) do
    Figure.set_limit(figure, {:y, ylim})
  end

  @doc """
  Adds legend for the graph with given details
  ## Examples

      iex> Matplotex.legend(figure, labels: ["A", "B", "C"])
      %Matplotex.Figure{}
  ### The `opts` are
  `labels, title, position, size`

  """

  # @spec legend(Figure.t(), keyword() | map()) :: Figure.t()
  # def legend(figure, opts) when is_map(opts) do
  #   Figure.add_legend(figure, opts)
  # end

  # def legend(figure, [h | _t] = opts) when is_tuple(h) do
  #   params = Enum.into(opts, %{})
  #   Figure.add_legend(figure, params)
  # end

  # def legend(figure, labels) when is_list(labels) do
  #   Figure.add_legend(figure, %{labels: labels})
  # end

  @doc """
  Function to update figure params
  ## Examples

      iex> Matplotex.figure(figure, figsize: {10,6}, margin: 0.1)
      %Matplotex.Figure{}
  """
  @deprecated
  def figure(figure, params) do
    Figure.update_figure(figure, params)
  end

  def set_figure_size(figure, size) do
    Figure.set_figure_size(figure, size)
  end

  def set_margin(figure, margin) do
    Figure.set_margin(figure, margin)
  end

  def hide_v_grid(figure) do
    Figure.hide_v_grid(figure)
  end

  def show_legend(figure) do
    Figure.show_legend(figure)
  end

  @doc """
  Function to update rc params, rc stands for runtime configuration
  ## Examples

       iex> Matplotex.set_rc_params(figure, figure_size: {10,6}, figure_dpi: 100)

  ### The RC params are
             figure_size: Figure size
             figure_dpi: dots per inch
             line_width: Main line width(axis, border, etc)
             line_style: Main line style("--", "-")
             x_tick_font_size: X tick font size,
             y_tick_font_size: Y tick font size
             x_label_font_size: X label font size
             y_label_font_size: y label font size
             legend_font_size: Legends font size
             legend_location: Legend location
             title_font: Title font size
             grid_color: grid color
             grid_linestyle:  grid linestyle
             grid_linewidth: grid line width
             grid_alpha: grid line alpha
             font_uom: font unit of measurement
  """
  def set_rc_params(figure, rc_params) do
    Figure.set_rc_params(figure, rc_params)
  end

  def show({stream, figure}) do
    Scatter.materialize(stream, figure)
    |> Sketch.call()
  end

  def show(figure) do
    figure
    |> Figure.materialize()
    |> Sketch.call()
  end
end
