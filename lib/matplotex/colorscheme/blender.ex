defmodule Matplotex.Colorscheme.Blender do
  @moduledoc false
  alias Matplotex.Colorscheme.Rgb

  @rgb_fields [:red, :green, :blue, :alpha]

  @type color :: %Rgb{
          red: :float,
          green: :float,
          blue: :float,
          alpha: :float
        }

  def mix(color1, color2, weight \\ 0.5) do
    p = weight
    w = p * 2 - 1
    a = color1.alpha - color2.alpha

    w1 = (if(w * a == -1, do: w, else: (w + a) / (1 + w * a)) + 1) / 2.0
    w2 = 1 - w1

    [r, g, b] =
      [:red, :green, :blue]
      |> Enum.map(fn key ->
        get_attribute(color1, key) * w1 + get_attribute(color2, key) * w2
      end)

    alpha = get_alpha(color1) * p + get_alpha(color2) * (1 - p)
    rgb(r, g, b, alpha)
  end

  defdelegate rgb(red, green, blue), to: Rgb
  defdelegate rgb(red, green, blue, alpha), to: Rgb

  @doc """
    Gets the `:red` property of the color.
  """
  @spec get_red(color) :: float
  def get_red(color), do: get_attribute(color, :red)

  @doc """
    Gets the `:green` property of the color.
  """
  @spec get_green(color) :: float
  def get_green(color), do: get_attribute(color, :green)

  @doc """
    Gets the `:blue` property of the color.
  """
  @spec get_blue(color) :: float
  def get_blue(color), do: get_attribute(color, :blue)

  @doc """
    Gets the `:hue` property of the color.
  """
  @spec get_hue(color) :: float
  def get_hue(color), do: get_attribute(color, :hue)

  @doc """
    Gets the `:saturation` property of the color.
  """
  @spec get_saturation(color) :: float
  def get_saturation(color), do: get_attribute(color, :saturation)

  @doc """
    Gets the `:lightness` property of the color.
  """
  @spec get_lightness(color) :: float
  def get_lightness(color), do: get_attribute(color, :lightness)

  @doc """
    Gets the `:alpha` property of the color.
  """
  @spec get_alpha(color) :: float
  def get_alpha(color), do: get_attribute(color, :alpha)

  @doc """
    Get's any color attribute from the color.
  """
  @spec get_attribute(color, atom()) :: float
  def get_attribute(color, key) do
    color
    |> cast_color_by_attribute(key)
    |> Map.fetch!(key)
  end

  defp cast_color_by_attribute(color, attribute) when attribute in @rgb_fields, do: color
end
