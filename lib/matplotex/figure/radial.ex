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
      def add_title(axes, title, opts) when is_binary(title) do
        title = create_text(title, opts)
        %{axes | title: title, show_title: true}
      end
    end
  end
end
