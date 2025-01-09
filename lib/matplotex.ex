defmodule Matplotex do
  @moduledoc """
  # Matplotex

  a lightweight and efficient library for Elixir projects that facilitates server-side
  SVG generation for data visualization. Designed to integrate seamlessly with Phoenix LiveView,
  it serves as a powerful tool for creating dynamic visualizations in web applications.

  it supports the following graphs
  - Line plots
  - Bar charts
  - Pie charts
  - Spline graphs
  - Histograms
  - Scatter plots

  The plotting of a graph comes with set of common parameters and set of plot specific parameters
  all of them will share with the corresponding function documentation, this section covers one examaple
  as a line plot.
  There are two approach to generate plots
  - by using specific function to set parameters
  - by using parameters along with options

  ```elixir
  alias Matplotex as: M

    x = [1, 2, 3, 4, 6, 6, 7]
    y = [1, 3, 4, 4, 5, 6, 7]

    frame_width = 6
    frame_height = 6
    size = {frame_width, frame_height}
    margin = 0.05
    font_size = "16pt"
    title_font_size = "18pt"
    ticks = [1, 2, 3, 4, 5, 6, 7]

    x
    |> M.plot(y)
    |> M.figure(%{figsize: size, margin: margin})
    |> M.set_title("The Plot Title")
    |> M.set_xlabel("X Axis")
    |> M.set_ylabel("Y Axis")
    |> M.set_xticks(ticks)
    |> M.set_yticks(ticks)
    |> M.set_xlim({4, 7})
    |> M.set_ylim({4, 7})
    |> M.set_rc_params(
      x_tick_font_size: font_size,
      y_tick_font_size: font_size,
      title_font_size: title_font_size,
      x_label_font_size: font_size,
      y_label_font_size: font_size,
      title_font_size: title_font_size
    )
    |> M.show()
  ```
  This module exposes all of the functions for setters
  and another approach is creating plots by using plot options the code is as follows
  ```elixir
  alis Matplotex as: M
   x = [1, 2, 3, 4, 6, 6, 7]
    y = [1, 3, 4, 4, 5, 6, 7]

    frame_width = 6
    frame_height = 6
    size = {frame_width, frame_height}
    margin = 0.05
    font_size = "16pt"
    title_font_size = "18pt"
    ticks = [0, 1, 2, 3, 4, 5, 6, 7]

    x
    |> M.plot(y,
      figsize: size,
      margin: margin,
      title: "The plot title",
      x_label: "X Axis",
      y_label: "Y Axis",
      x_tick: ticks,
      y_tick: ticks,
      x_limit: {0, 7},
      y_limit: {0, 7},
      x_tick_font_size: font_size,
      y_tick_font_size: font_size,
      title_font_size: title_font_size,
      x_label_font_size: font_size,
      y_label_font_size: font_size,
      y_tick_font_text_anchor: "start"
    )
    |> M.show()
  ```
  just for simplicity and convenience of the user it is keeping both patterns, no difference on using one on another

  So the user has the control on the all parameters on the inner elements of the chart

  ## Rc Params
  In the first example along with the setter functions you might noticed M.set_rc_params/2
  The role of this function is similar to other functions we are keeping some values with the plot data
  and the acronym RC stands for Runtime configuration, the plot data holds the labels limits ticks, etc
  The RC params are holding the font size, color, style etc, by defaul one chart object kickstart with some default values
  just for the sake of it needed some values, by default all the fonts are Areal, Veradana, sans-serif  and using standard font size 12
  if a user creates a plots with no inputs for any of these the plot will be choosing the default values
  besides font configuration Rc params covers
  `line_width, line_style, grid_color, grid_linestyle, grid_alpha, tick_line_length, x_padding, y_padding, legend_width`
  There is two types of padding `x_padding, y_padding` and `padding` the perfect use of those can be found on upcoming plot specific documentations

  ## Elements
  The output format of the plot is SVG will support more formats in future, anyway the svg is a group of some elements put together, throught the execution
  it is generating those elements through elixir data structure, all element data structure contains some svg equivalent data that converts the elements to
  SVG string, the output SVG string can be used directly in the web application.

  ## Figure
  The execution a plot carriec out by a data structure named Matplotex.Figure it holds all the adequate information to generate a figure it containst the keys
  `:figsize` - is a tuple carries width and height of the figure eg: {10,6}
  `:axes` - is another object that will varie according to the plot
  `:rc_params` - the runtime configurations
  `:margin` - the margin of the figure

  ## M.show/1
  All examples above using this function `M.show/1` after a plot generation API call
  The all APIs from this module is ment to return an svg equivalent Data Matplotex.Figure with distinct object associated with the `axes` key, so to convert that data to
  an SVG chart  use  `M.show/1`

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

  @doc """
    Generates a bar chart using the provided values and bar widths.

  ## Parameters

    - `values` (list of numbers): A list of numerical values representing the heights of the bars in the chart.
    - `width` (floatiung point number): The width of each bar in inches.
    - `opts` (keyword list): It will support all opts mentioned above, some bar specific options are there those are
        - `:label` (string): Label for specific dataset passed on first argument.
        - `:color` (string): Color of the bar.
        - `:edge_color` (string): Color of the edge of the bar.


  ## Returns

    - A figure with the axes of a bar chart
  ```elixir

      alias Matplotex as: M
    categories = ["apple", "banana", "fig", "avocado"]
      values1 = [22, 33, 28, 34]
      iex> Matplotex.bar(width, values1, width, label: "Dataset1", color: "#255199")
      %M.Figure{axes: %M.Figure.Areal.BarChart{...}, ...}
    ```

  This function takes a list of numerical `values` and a single `width` value to create a bar chart where:
    - The height of each bar corresponds to its respective value from the list.
    - Each bar has the specified constant width.
  """
  @spec bar(list(), float()) :: Matplotex.Figure.t()
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

  @doc """
  Adds an additional dataset to a bar plot in the given `%Figure{}`.

  This function allows you to append multiple datasets to a bar plot by providing new values and corresponding options. Each dataset can be customized with options such as color, label, and bar width.

  ## Parameters

    - `figure` (%Figure{}): The figure to which the new dataset will be added.
    - `values` (list): A list of numerical values representing the heights of the bars in the new dataset.
    - `width` (float): The width of the bars in the dataset.
    - `opts` (keyword list, optional): A set of options for customizing the appearance of the new dataset, such as color and label.

  ## Usage

  This function is used when generating multi-bar plots to represent data from multiple datasets. Here's an example demonstrating its usage:

  ```elixir
  alias Matplotex, as: M

  categories = ["apple", "banana", "fig", "avocado"]
  values1 = [22, 33, 28, 34]
  values2 = [53, 63, 59, 60]
  width = 0.22

  Matplotex.bar(width, values1, width, label: "Dataset1", color: "#255199")
  |> M.bar(width, values2, width, label: "Dataset2", color: "#D3D3D3")
  """
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

  @doc """
  Creates a scatter plot based on the given `x` and `y` values, with optional customization provided via `opts`.

  ## Parameters

    - `x` (list): A list of numerical values representing the x-coordinates.
    - `y` (list): A list of numerical values representing the y-coordinates.
    - `opts` (keyword list, optional): A set of options for customizing the scatter plot, such as color, marker size, and labels.

  ## Examples

  ```elixir
  # Basic usage:
  x = [1, 2, 3, 4]
  y = [10, 20, 30, 40]
  opts = [color: "blue", marker_size: 5]

  iex> M.scatter(x, y, opts)
   %M.Figure{axes: %Matplotex.Figure.Areal.Scatter{...}, ...}
  """
  def scatter(x, y) do
    scatter(x, y, [])
  end

  def scatter(x, y, opts) do
    Scatter.create(%Figure{axes: %Scatter{}}, {x, y}, opts)
  end

  @doc """
  Adds an additional dataset to a scatter plot in the given `%Figure{}`.

  This function allows you to overlay multiple scatter plots on the same figure by providing new `x` and `y` values, along with customization options via `opts`.

  ## Parameters

    - `figure` (%Figure{}): The figure to which the new dataset will be added.
    - `x` (list): A list of numerical values representing the x-coordinates of the new dataset.
    - `y` (list): A list of numerical values representing the y-coordinates of the new dataset.
    - `opts` (keyword list, optional): A set of options for customizing the appearance of the new dataset, such as color, marker style, line style, and labels.

  ## Usage

  This function is typically used when you want to generate multi-pattern scatter plots with multiple datasets. The following example demonstrates its usage:

  ```elixir
  x = [1, 2, 3, 4, 5]

  # Dataset 1
  y1 = [20, 5, 12, 16, 25]

  # Dataset 2
  y2 = [10, 1, 6, 10, 15]

  # Dataset 3
  y3 = [17, 5, 8, 12, 17]

  x
  |> Matplotex.scatter(y1, color: "blue", linestyle: "_", marker: "o", label: "Dataset 1")
  |> Matplotex.scatter(x, y2, color: "red", linestyle: "--", marker: "^", label: "Dataset 2")
  |> Matplotex.scatter(x, y3, color: "green", linestyle: "-.", marker: "s", label: "Dataset 3")
  """
  def scatter(%Figure{} = figure, x, y, opts) do
    figure
    |> show_legend()
    |> Scatter.create({x, y}, opts)
  end

  @doc """
  Generates a pie chart based on the provided data, labels, and options.

  ### Parameters:
  - `sizes` (list of integers/floats): Percentages or proportions for each slice of the pie chart.
  - `opts` (keyword list): Options to customize the chart, such as:
    - `:labels` (list of strings): Labels for each slice.
    - `:colors` (list of strings): Colors for the slices.

  ### Example:

  ```elixir
  # Percentages for each slice
  sizes = [25, 35, 20, 20]

  # Labels for each slice
  labels = ["A", "B", "C", "D"]

  # Colors for the slices
  colors = ["lightblue", "lightgreen", "orange", "pink"]

  # Generate the pie chart
  sizes
  |> Matplotex.pie(colors: colors, labels: labels)

  %M.Figure{axes: %Matplotex.Figure.Radial.Pie{...}, ...}
  """
  def pie(sizes, opts \\ []) do
    Pie.create(%Figure{axes: %Pie{}}, sizes, opts)
  end

  @doc """
  Generates a line plot using the provided `x` and `y` data points.
  ##Parameters
  `x`: A list of x-coordinates for the data points (e.g., [1, 2, 3]).
  `y`: A list of y-coordinates corresponding to x (e.g., [2, 4, 6]).
  `opts`:  it also expect some plot specific options such as
       `color`: line color
       `linestyle`: line style
       `marker`: marker style

  ### Example

  ```elixir
  # Define the data points
  x = [1, 2, 3, 4, 6, 6, 7]
  y = [1, 3, 4, 4, 5, 6, 7]

  # Specify plot configurations
  frame_width = 6
  frame_height = 6
  size = {frame_width, frame_height}
  margin = 0.05
  font_size = "16pt"
  title_font_size = "18pt"
  ticks = [1, 2, 3, 4, 5, 6, 7]

  # Create and configure the plot
  x
  |> Matplotex.plot(y)                                # Create a line plot
  |> Matplotex.figure(%{                              # Configure the figure
       figsize: size,
       margin: margin
     })
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

  @doc """
  Adds an additional dataset to a figure for creating multi-line plots.

  This function allows you to overlay multiple datasets onto a single figure, enabling the creation of multi-line plots for better data visualization and comparison.

  ## Parameters

  - `figure` (%Figure{}): The figure to which the new dataset will be added.
  - `x` (list): A list of x-coordinates for the new dataset.
  - `y` (list): A list of y-coordinates corresponding to the x-coordinates.

  ## Usage

  Use this function when you need to generate multi-line plots with multiple datasets. Below is an example of its usage:

  ```elixir
  # X-axis values
  x = [1, 2, 3, 4, 5]

  # Dataset 1
  y1 = [1, 4, 9, 16, 25]

  # Dataset 2
  y2 = [1, 3, 6, 10, 15]

  # Dataset 3
  y3 = [2, 5, 7, 12, 17]

  # Plotting multiple datasets on the same figure
  x
  |> Matplotex.plot(y1, color: "blue", linestyle: "_", marker: "o", label: "Dataset 1")
  |> Matplotex.plot(x, y2, color: "red", linestyle: "--", marker: "^", label: "Dataset 2")
  |> Matplotex.plot(x, y3, color: "green", linestyle: "-.", marker: "s", label: "Dataset 3")
  """
  def plot(%Figure{} = figure, x, y, opts) do
    figure
    |> show_legend()
    |> LinePlot.create({x, y}, opts)
  end

  @doc """
  Creates a histogram with the given data and bins.

  This function generates a histogram visualization using the provided data, number of bins, and additional plot configuration options.
  ## Parameters
   - `data`: list of random distributions of numbers
   - `bins`: number of bins to get the density of each distribution
   - `opts` (keyword list, optional): additional plot configuration options, such as, color, edge color, alpha
  ## Examples

  ```elixir
  # Generate a list of random values from a normal distribution
  values =
    Nx.Random.key(12)
    |> Nx.Random.normal(0, 1, shape: {1000})
    |> elem(0)
    |> Nx.to_list()

  # Specify the number of bins for the histogram
  bins = 30

  # Create the histogram with labels, title, and styling
  Matplotex.hist(
    values,
    bins,
    x_label: "Value",
    y_label: "Frequency",
    title: "Histogram",
    color: "blue",
    edge_color: "black",
    alpha: 0.7,
    x_ticks_count: 9
  )
  """
  def hist(data, bins), do: hist(data, bins, [])

  @doc """
  Adds an additional dataset to a histogram plot.

  This function allows you to overlay multiple datasets on the same figure, enabling the creation of combined histograms for comparative analysis.

  ## Parameters

  - `figure` (%Figure{}): The figure to which the new dataset will be added.
  - `data` (list): A list of random numbers representing the distribution to be added.
  - `bins` (integer): The number of bins to divide the dataset into for density calculation.

  ## Usage

  Use this function when you need to generate multiple histograms from different datasets on the same figure. This is particularly useful for comparing distributions.

  ## Example

  ```elixir
  # Generate the first dataset
  values1 =
    Nx.Random.key(12)
    |> Nx.Random.normal(0, 1, shape: {1000})
    |> elem(0)
    |> Nx.to_list()

  # Generate the second dataset
  values2 =
    Nx.Random.key(13)
    |> Nx.Random.normal(0, 1, shape: {500})
    |> elem(0)
    |> Nx.to_list()

  # Define the number of bins
  bins = 30

  # Create a histogram with multiple datasets
  Matplotex.hist(values1, bins,
    x_label: "Value",
    y_label: "Frequency",
    title: "Histogram",
    color: "blue",
    edge_color: "black",
    alpha: 0.7,
    x_ticks_count: 9
  )
  |> Matplotex.hist(values2, bins, color: "red")
  """
  def hist(%Figure{} = figure, data, bins) do
    Histogram.create(figure, {data, bins}, [])
  end

  def hist(data, bins, opts) do
    Histogram.create(%Figure{axes: %Histogram{}}, {data, bins}, opts)
  end

  def hist(%Figure{} = figure, data, bins, opts) do
    Histogram.create(figure, {data, bins}, opts)
  end

  @doc """
  Generates a spline graph based on the provided datasets.

  This function creates a smooth curve that connects the data points (x, y) using spline interpolation, ideal for visualizing continuous relationships between two variables.

  ## Parameters

  - `x` (list): A list of x-coordinates for the data points.
  - `y` (list): A list of y-coordinates corresponding to the x-coordinates.
  - `opts` (keyword list, optional): A list of additional configuration options for the plot. These can include attributes like `color`, `line_style`, `marker`, `x_label`, `y_label`, and more.

  ## Example

  ```elixir
  # Generate x and y data
  x_nx = Nx.linspace(0, 10, n: 100)
  x = Nx.to_list(x_nx)
  y = x_nx |> Nx.sin() |> Nx.to_list()

  # Plot a spline graph with optional configurations
  Matplotex.spline(x, y, x_label: "X", y_label: "Y", edge_color: "green")
  """
  def spline(x, y), do: spline(x, y, [])
  def spline(x, y, opts), do: spline(%Figure{axes: %Spline{}}, x, y, opts)

  @doc """
  Adds an additional spline to an existing spline graph.

  This function allows you to extend an existing spline plot by adding another spline with different data points. It is ideal for comparing multiple datasets on the same plot.

  ## Parameters

  - `figure` (%Figure{}): The existing figure (spline graph) to which the new spline will be added.
  - `x` (list): A list of x-coordinates for the new spline.
  - `y` (list): A list of y-coordinates corresponding to the x-coordinates for the new spline.
  - `opts` (keyword list, optional): Additional configuration options for the plot. This can include attributes like:
    - `color`: The color of the spline.
    - `line_style`: The style of the line (e.g., dashed, solid, etc.).
    - `marker`: Marker style for the data points (e.g., circle, square, etc.).
    - `label`: Label for the new spline.

  ## Example

  ```elixir
  # Generate x and y data
  x_nx = Nx.linspace(0, 10, n: 100)
  x = Nx.to_list(x_nx)
  y1 = x_nx |> Nx.sin() |> Nx.to_list()
  y2 = x_nx |> Nx.cos() |> Nx.to_list()

  # Create an initial spline and add another one
  Matplotex.spline(x, y1, x_label: "X", y_label: "Y", edge_color: "green")
  |> Matplotex.spline(x, y2, x_label: "X", y_label: "Y", edge_color: "red")
  """
  def spline(%Figure{} = figure, x, y, opts) do
    Spline.create(figure, {x, y}, opts)
  end

  @doc """
  Sets X labels for the graph with given font details

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
