defmodule Matplotex.Figure.Radial do
  @callback create(struct(), list(), keyword()) :: struct()
  @callback materialize(struct()) :: struct()

  defmacro __using__(_) do
    quote do
      import Matplotex.Blueprint.Chord
      @behaviour Matplotex.Figure.Radial

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      alias Matplotex.Figure.Text
      alias Matplotex.Figure.Lead
      alias Matplotex.Figure.Cast

      def add_title(axes, title, opts) when is_binary(title) do
        %{axes | title: title, show_title: true}
      end

      def materialized(figure) do
        figure
        |> Lead.focus_to_origin()
        |> Lead.set_border()
        |> Cast.cast_border()
        |> Cast.cast_title()
      end
    end
  end
end
