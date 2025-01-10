defmodule Matplotex.Figure.Radial do
@moduledoc false
  alias Matplotex.Utils.Algebra

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
      alias Matplotex.Figure.RcParams
      alias Matplotex.Figure
      alias Matplotex.Figure.Areal.Region
      alias Matplotex.Utils.Algebra

      @zero_to_move 0

      def add_title(axes, title, opts) when is_binary(title) do
        %{axes | title: title, show_title: true}
      end

      def materialized(figure) do
        figure
        |> Lead.set_regions_radial()
        |> Cast.cast_border()
        |> Cast.cast_title_by_region()
      end

      def set_region_title(
            %Figure{
              axes:
                %{
                  title: title,
                  center: _center,
                  border: {lx, _by, _rx, ty},
                  size: {width, _height}
                } =
                  axes,
              rc_params: %RcParams{title_font: title_font}
            } = figure
          ) do
        space_for_title = Lead.height_required_for_text(title_font, title)

        {x_region_title, y_region_title} =
          Algebra.transform_given_point(@zero_to_move, -space_for_title, lx, ty)

        %Figure{
          figure
          | axes: %{
              axes
              | region_title: %Region{
                  x: x_region_title,
                  y: y_region_title,
                  width: width,
                  height: space_for_title
                }
            }
        }
      end

      def set_region_title(figure), do: figure

      def set_region_legend(
            %Figure{
              figsize: {fwidth, _fheight},
              rc_params: %RcParams{legend_width: legend_width},
              axes:
                %{
                  border: {_lx, by, rx, ty},
                  show_legend: true,
                  region_title: %Region{y: y_region_title, height: height_region_title}
                } = axes
            } = figure
          ) do
        width_region_legend = fwidth * legend_width
        height_region_legend = abs(by - y_region_title)

        {x_region_legend, y_region_legend} =
          Algebra.transform_given_point(rx, abs(ty), -width_region_legend, height_region_title)
          |> Algebra.flip_y_coordinate()

        %Figure{
          figure
          | axes: %{
              axes
              | region_legend: %Region{
                  x: x_region_legend,
                  y: y_region_legend,
                  width: width_region_legend,
                  height: height_region_legend
                }
            }
        }
      end

      def set_region_legend(figure), do: figure

      def set_region_content(
            %Figure{
              axes:
                %{
                  border: {lx, by, _rx, _ty},
                  region_title: %Region{height: height_region_title},
                  region_legend: %Region{width: width_region_legend},
                  size: {width, height}
                } = axes
            } = figure
          ) do
        width_region_content = width - width_region_legend
        height_region_content = height - height_region_title

        %Figure{
          figure
          | axes: %{
              axes
              | region_content: %Region{
                  x: lx,
                  y: by,
                  width: width_region_content,
                  height: height_region_content
                }
            }
        }
      end

      def set_region_content(figure), do: figure
    end
  end
end
