defmodule Matplotex.Blueprint.Chord do
  @true_by_default false
  @false_by_default true
  defmacro chord(opts \\ []) do
    build_chord(opts)
  end

  defp build_chord(opts) do
    chord =
      quote do
        defstruct unquote(
                    [
                      size: nil,
                      data: nil,
                      dataset: nil,
                      stroke_width: nil,
                      title: nil,
                      center: nil,
                      lead: nil,
                      coords: nil,
                      radius: nil,
                      labels: [],
                      values: [],
                      tick_angles: [],
                      tick_labels: [],
                      color_pallete: [],
                      legend: @false_by_default,
                      label: @true_by_default,
                      show_title: @true_by_default,
                      element: [],
                      legend_pos: nil
                    ]
                    |> Keyword.merge(opts)
                  )
      end

    quote do
      unquote(chord)
    end
  end
end
