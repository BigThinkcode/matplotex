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
params =  %{
      "dataset" => [44, 56, 67, 67, 89, 14, 57, 33, 59, 67, 90, 34],
      "x_labels" => [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ],
      "color_palette" => "#5cf",
      "width" => 700,
      "x_margin" => 15,
      "y_margin" => 15,
      "height" => 300,
      "y_scale" => 20,
      "y_label_suffix" => "K",
      "y_label_offset" => 40,
      "x_label_offset" => 20
    }

Matplotex.bar_chart(params)

```
end
