defmodule Matplotex do
  @moduledoc """
  Module to generate a graph.
  """
  alias Matplotex.Figure
  def barchart(params) do
    Matplotex.BarChart.create(params)
  end

  def pie_chart(params) do
    Matplotex.PieChart.create(params)
  end

  @doc """
  Creates a line plot with given x and y data.

  ## Examples

      iex> Matplotex.plot([1, 2, 3], [4, 5, 6])
      %Matplotex.Figure{}

  """

  @spec plot(list(), list()) :: Figure.t()
  def plot(x, y) do
    Matplotex.LinePlot.create(x, y)
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
  def set_xticks(figure, ticks) do
    Figure.add_ticks(figure, {:x, ticks})
  end

  @doc """
  Sets Y tick labels for the graph with given details
  ## Examples

      iex> Matplotex.set_yticks(figure, [10, 20, 30, 40, 50])
      %Matplotex.Figure{}
  """

  @spec set_yticks(Figure.t(), list()) :: Figure.t()
  def set_yticks(figure, ticks) do
    Figure.add_ticks(figure, {:y, ticks})
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

  @spec legend(Figure.t(), keyword() | map()) :: Figure.t()
  def legend(figure, opts) when is_map(opts) do
    Figure.add_legend(figure, opts)
  end

  def legend(figure, [h | _t] = opts) when is_tuple(h) do
    params = Enum.into(opts, %{})
    Figure.add_legend(figure, params)
  end

  def legend(figure, labels) when is_list(labels) do
    Figure.add_legend(figure, %{labels: labels})
  end

  @doc """
  Function to update figure params
  ## Examples

      iex> Matplotex.figure(figure, figsize: {10,6}, margin: 0.1)
      %Matplotex.Figure{}
  """

  def figure(figure, params) do
    Figure.update_figure(figure, params)
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
end
