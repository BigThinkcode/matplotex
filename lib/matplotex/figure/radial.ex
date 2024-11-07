defmodule Matplotex.Figure.Radial do


  @callback create(struct(), tuple(), keyword()) :: struct()
  @callback materialyze(struct()) :: struct()

  defmacro __using__(_) do
    quote do
      import Matplotex.Blueprint.Chord
      @behaviour Matplotex.Figure.Areal

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      alias Matplotex.Figure.Text
      def add_title(axes, title, opts) when is_binary(title) do
        title = Text.create_text(title, opts)
        %{axes | title: title, show_title: true}
      end

      def materialized(figure) do
        figure
        |>Lead.focus_to_origin()
        |>Cast.cast_title()
      end
    end
  end
end
