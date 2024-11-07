defmodule Matplotex.Blueprint.Chord do
  alias Matplotex.Figure.Coords
  alias Matplotex.Figure.TwoD

  @true_by_default false
  @false_by_default true
  defmacro chord(opts \\ []) do
    build_chord(opts)
  end

  defp build_chord(_opts) do
    chord =
      quote do
        defstruct unquote([
                    :size,
                    :data,
                    :dataset,
                    :stroke_width,
                    :title,
                    labels: [],
                    values: [],
                    tick_angles: [],
                    tick_labels: [],
                    center: %TwoD{},
                    lead: %TwoD{},
                    color_pallete: [],
                    legend: @false_by_default,
                    label: @true_by_default,
                    show_title: @true_by_default,
                    coords: %Coords{}
                  ])
      end

    quote do
      unquote(chord)
    end
  end
end
