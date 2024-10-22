# Matplotex 
An Elixir Library to generate SVG graphs and plots from elixir data

### Install 
```elixir 
def deps do 
[
    {:matplotex, git: "git@github.com:BigThinkcode/matplotex.git" }
]
```

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


    


