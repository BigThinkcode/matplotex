# <img src="assets/images/matplotex_logo.png" height="50" /> Matplotex

Matplotex is a lightweight, efficient library for Elixir projects that enables server-side SVG generation for data visualization, designed to integrate seamlessly with Phoenix LiveView.
<div style="display: flex; flex-wrap: wrap; justify-content: space-between;">
<img src="assets/images/line_plot_readme.svg" width="45%"/>
<img src="assets/images/scatter_plot_readme.svg"width="45%"/>
<img src="assets/images/bar_readme.svg"width="45%"/>
<img src="assets/images/pie_readme.svg" width="50%" style="margin-bottom: 45px;"/>
</div>

### Installation

The package can be installed by adding `matplotex` to your list of dependencies in `mix.exs`.

```elixir
def deps do
[
    {:matplotex, git: "git@github.com:BigThinkcode/matplotex.git" }
]
```

### Sample SVG generation

```elixir
x = [1, 3, 7, 4, 2, 5, 6]
y = [1, 3, 7, 4, 2, 5, 6]

frame_width = 8
frame_height = 6
size = {frame_width, frame_height}
margin = 0.05
font_size = "16pt"
title_font_size = "18pt"
ticks = [1, 2, 3, 4, 5, 6, 7]

x
|> Matplotex.plot(y)
|> Matplotex.figure(%{figsize: size, margin: margin})
|> Matplotex.set_title("The Plot Title")
|> Matplotex.set_xlabel("X Axis")
|> Matplotex.set_ylabel("Y Axis")
|> Matplotex.set_xticks(ticks)
|> Matplotex.set_yticks(ticks)
|> Matplotex.set_rc_params(
  x_tick_font_size: font_size,
  y_tick_font_size: font_size,
  title_font_size: title_font_size,
  x_label_font_size: font_size,
  y_label_font_size: font_size,
  title_font_size: title_font_size
)
|> Matplotex.show()

```

### Contributing
We welcome contributions to the `matplotex` project! If you would like to improve the library, fix bugs, or add new features, please follow these steps:
1. Fork the repository.
2. Create a new branch (git checkout -b feature-name).
3. Make your changes.
4.  Add your changes to the branch  (git add \<changed files\>).
5. Commit your changes (git commit -m 'Add new feature').
6. Push to the branch (git push origin feature-name).
7. Open a Pull Request.

**Happy Contributing !!!**

