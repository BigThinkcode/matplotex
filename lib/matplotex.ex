defmodule Matplotex do
  @moduledoc """
  Documentation for `Matplotex`.
  """
alias Matplotex.Figure

  @doc """
  Hello world.

  ## Examples

      iex> Matplotex.hello()
      :world

  """
  def barchart(params) do
    Matplotex.BarChart.create(params)
  end

  def pie_chart(params) do
    Matplotex.PieChart.create(params)
  end
  @spec plot(list(), list()) :: Figure.t()
  def plot(x, y) do
    Matplotex.LinePlot.create(x,y)
  end
  @spec set_xlabel(Figure.t(), String.t()) :: Figure.t()
  def set_xlabel(figure, label) do
    Figure.add_label(figure, {:x, label})
  end
  @spec set_ylabel(Figure.t(), String.t()) :: Figure.t()
  def set_ylabel(figure, label) do
    Figure.add_label(figure, {:y, label})
  end
  @spec set_title(Figure.t(), String.t()) :: Figure.t()
  def set_title(figure, title) do
    Figure.add_title(figure, title)
  end
  @spec set_xticks(Figure.t(), list()) :: Figure.t()
  def set_xticks(figure, ticks) do
    Figure.add_ticks(figure, {:x, ticks})
  end
  @spec set_yticks(Figure.t(), list()) :: Figure.t()
  def set_yticks(figure, ticks) do
    Figure.add_ticks(figure, {:y, ticks})
  end
  @spec set_xlim(Figure.t(), tuple()):: Figure.t()
  def set_xlim(figure, xlim) do
    Figure.set_limit(figure, {:x, xlim})
  end
  @spec set_ylim(Figure.t(), tuple()) :: Figure.t()
  def set_ylim(figure, ylim) do
    Figure.set_limit(figure, {:y, ylim})
  end
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
end
