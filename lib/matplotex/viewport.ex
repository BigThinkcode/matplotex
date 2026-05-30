defmodule Matplotex.Viewport do
  @moduledoc """
  Interactive view window — pan and zoom state.

  `zoom_x` / `zoom_y` are scale factors (1.0 = no zoom, 2.0 = 2× zoom-in).
  `pan_x` / `pan_y` are offsets in normalized [0,1] space.

  The viewport is encoded as a 3×3 matrix and pre-multiplied into the
  data-to-pixel transform, so zooming never touches the data layer.

      full view:  zoom=1.0, pan=0.0
      2× zoom-in: zoom=2.0, pan chosen so focus stays centred

  `domain_x` / `domain_y` override axis domain when set — used when the
  server has zoomed far enough to re-fetch higher-resolution data.
  """

  @type t :: %__MODULE__{
          zoom_x: float(),
          zoom_y: float(),
          pan_x: float(),
          pan_y: float(),
          domain_x: {float(), float()} | nil,
          domain_y: {float(), float()} | nil
        }

  defstruct zoom_x: 1.0,
            zoom_y: 1.0,
            pan_x: 0.0,
            pan_y: 0.0,
            domain_x: nil,
            domain_y: nil

  @doc """
  Returns the 3×3 homogeneous viewport matrix in normalized [0,1] space.

  Encodes: scale around the pan centre, then translate.

      [zoom_x,  0,      -pan_x * zoom_x]
      [0,       zoom_y, -pan_y * zoom_y]
      [0,       0,       1             ]
  """
  def to_matrix(%__MODULE__{zoom_x: zx, zoom_y: zy, pan_x: px, pan_y: py}) do
    Nx.tensor(
      [
        [zx, 0.0, -px * zx],
        [0.0, zy, -py * zy],
        [0.0, 0.0, 1.0]
      ],
      type: :f64
    )
  end

  @doc "Applies a scroll-wheel zoom centred on `{focus_nx, focus_ny}` in normalized space."
  def zoom(%__MODULE__{} = vp, delta, {focus_nx, focus_ny}) do
    factor = if delta > 0, do: 1.15, else: 1 / 1.15
    new_zx = vp.zoom_x * factor
    new_zy = vp.zoom_y * factor

    new_px = focus_nx - (focus_nx - vp.pan_x) / factor
    new_py = focus_ny - (focus_ny - vp.pan_y) / factor

    %{vp | zoom_x: new_zx, zoom_y: new_zy, pan_x: new_px, pan_y: new_py}
  end

  @doc "Pans by `{dx, dy}` in normalized space."
  def pan(%__MODULE__{} = vp, dx, dy) do
    %{vp | pan_x: vp.pan_x + dx / vp.zoom_x, pan_y: vp.pan_y + dy / vp.zoom_y}
  end

  @doc "Resets to the full-data view."
  def reset(_vp), do: %__MODULE__{}
end
