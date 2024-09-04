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


![barchart](https://github.com/user-attachments/assets/24b72520-297c-4013-b2c5-ae1a98294954)<svg width="700"
    height="300"
    version="1.1"
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    style="top: 0px;
    left: 0px;
    position: absolute;">
    <g>
    
    <line x1="55"
    y1="250"
    x2="700"
    y2="250"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
    <line x1="55"
    y1="250"
    x2="55"
    y2="0"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
    <line x1="55"
    y1="200.0"
    x2="700"
    y2="200.0"
    fill="rgba(0,0,0,0)"
    stroke="#ddd"
    stroke-width="1"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
    <line x1="55"
    y1="150.0"
    x2="700"
    y2="150.0"
    fill="rgba(0,0,0,0)"
    stroke="#ddd"
    stroke-width="1"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
    <line x1="55"
    y1="100.0"
    x2="700"
    y2="100.0"
    fill="rgba(0,0,0,0)"
    stroke="#ddd"
    stroke-width="1"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
    <line x1="55"
    y1="50.0"
    x2="700"
    y2="50.0"
    fill="rgba(0,0,0,0)"
    stroke="#ddd"
    stroke-width="1"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
    <line x1="55"
    y1="0.0"
    x2="700"
    y2="0.0"
    fill="rgba(0,0,0,0)"
    stroke="#ddd"
    stroke-width="1"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
       
    
    <line x1="55"
    y1="200.0"
    x2="50"
    y2="200.0"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.yaxis"
     fill="black"
     x="15"
     y="200.0"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 15, 200.0)"
     dominant-baseline="hanging">
     20K
    </text>

    
    
    <line x1="55"
    y1="150.0"
    x2="50"
    y2="150.0"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.yaxis"
     fill="black"
     x="15"
     y="150.0"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 15, 150.0)"
     dominant-baseline="hanging">
     40K
    </text>

    
    
    <line x1="55"
    y1="100.0"
    x2="50"
    y2="100.0"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.yaxis"
     fill="black"
     x="15"
     y="100.0"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 15, 100.0)"
     dominant-baseline="hanging">
     60K
    </text>

    
    
    <line x1="55"
    y1="50.0"
    x2="50"
    y2="50.0"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.yaxis"
     fill="black"
     x="15"
     y="50.0"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 15, 50.0)"
     dominant-baseline="hanging">
     80K
    </text>

    
    
    <line x1="55"
    y1="0.0"
    x2="50"
    y2="0.0"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.yaxis"
     fill="black"
     x="15"
     y="0.0"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 15, 0.0)"
     dominant-baseline="hanging">
     100K
    </text>

    
    
    <line x1="83.875"
    y1="250"
    x2="83.875"
    y2="255"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.xaxis"
     fill="black"
     x="60.25"
     y="270"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 60.25, 270)"
     dominant-baseline="hanging">
     Jan
    </text>

    
    
    <line x1="136.375"
    y1="250"
    x2="136.375"
    y2="255"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.xaxis"
     fill="black"
     x="112.75"
     y="270"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 112.75, 270)"
     dominant-baseline="hanging">
     Feb
    </text>

    
    
    <line x1="188.875"
    y1="250"
    x2="188.875"
    y2="255"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.xaxis"
     fill="black"
     x="165.25"
     y="270"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 165.25, 270)"
     dominant-baseline="hanging">
     Mar
    </text>

    
    
    <line x1="241.375"
    y1="250"
    x2="241.375"
    y2="255"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.xaxis"
     fill="black"
     x="217.75"
     y="270"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 217.75, 270)"
     dominant-baseline="hanging">
     Apr
    </text>

    
    
    <line x1="293.875"
    y1="250"
    x2="293.875"
    y2="255"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.xaxis"
     fill="black"
     x="270.25"
     y="270"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 270.25, 270)"
     dominant-baseline="hanging">
     May
    </text>

    
    
    <line x1="346.375"
    y1="250"
    x2="346.375"
    y2="255"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.xaxis"
     fill="black"
     x="322.75"
     y="270"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 322.75, 270)"
     dominant-baseline="hanging">
     Jun
    </text>

    
    
    <line x1="398.875"
    y1="250"
    x2="398.875"
    y2="255"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.xaxis"
     fill="black"
     x="375.25"
     y="270"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 375.25, 270)"
     dominant-baseline="hanging">
     Jul
    </text>

    
    
    <line x1="451.375"
    y1="250"
    x2="451.375"
    y2="255"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.xaxis"
     fill="black"
     x="427.75"
     y="270"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 427.75, 270)"
     dominant-baseline="hanging">
     Aug
    </text>

    
    
    <line x1="503.875"
    y1="250"
    x2="503.875"
    y2="255"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.xaxis"
     fill="black"
     x="480.25"
     y="270"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 480.25, 270)"
     dominant-baseline="hanging">
     Sep
    </text>

    
    
    <line x1="556.375"
    y1="250"
    x2="556.375"
    y2="255"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.xaxis"
     fill="black"
     x="532.75"
     y="270"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 532.75, 270)"
     dominant-baseline="hanging">
     Oct
    </text>

    
    
    <line x1="608.875"
    y1="250"
    x2="608.875"
    y2="255"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.xaxis"
     fill="black"
     x="585.25"
     y="270"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 585.25, 270)"
     dominant-baseline="hanging">
     Nov
    </text>

    
    
    <line x1="661.375"
    y1="250"
    x2="661.375"
    y2="255"
    fill="rgba(0,0,0,0)"
    stroke="black"
    stroke-width="3"
    shape-rendering="crispEdges"
    stroke-linecap="square"/>

    
        <text tag="tick.xaxis"
     fill="black"
     x="637.75"
     y="270"
     font-size="16pt"
     font-weight="normal"
     font-family="Arial, Verdana, sans-serif"
     font-style="normal"
     transform="rotate(, 637.75, 270)"
     dominant-baseline="hanging">
     Dec
    </text>

    
       
    <rect stroke="rgba(0,0,0,0)"
    fill="#5cf"
    x="60.25"
    y="140.0"
    width="47.25"
    height="110.0"
    stroke-width="1"
    filter="">
    </rect>
    <rect stroke="rgba(0,0,0,0)"
    fill="#5cf"
    x="112.75"
    y="110.0"
    width="47.25"
    height="140.0"
    stroke-width="1"
    filter="">
    </rect>
    <rect stroke="rgba(0,0,0,0)"
    fill="#5cf"
    x="165.25"
    y="82.5"
    width="47.25"
    height="167.5"
    stroke-width="1"
    filter="">
    </rect>
    <rect stroke="rgba(0,0,0,0)"
    fill="#5cf"
    x="217.75"
    y="82.5"
    width="47.25"
    height="167.5"
    stroke-width="1"
    filter="">
    </rect>
    <rect stroke="rgba(0,0,0,0)"
    fill="#5cf"
    x="270.25"
    y="27.5"
    width="47.25"
    height="222.5"
    stroke-width="1"
    filter="">
    </rect>
    <rect stroke="rgba(0,0,0,0)"
    fill="#5cf"
    x="322.75"
    y="215.0"
    width="47.25"
    height="35.0"
    stroke-width="1"
    filter="">
    </rect>
    <rect stroke="rgba(0,0,0,0)"
    fill="#5cf"
    x="375.25"
    y="107.5"
    width="47.25"
    height="142.5"
    stroke-width="1"
    filter="">
    </rect>
    <rect stroke="rgba(0,0,0,0)"
    fill="#5cf"
    x="427.75"
    y="167.5"
    width="47.25"
    height="82.5"
    stroke-width="1"
    filter="">
    </rect>
    <rect stroke="rgba(0,0,0,0)"
    fill="#5cf"
    x="480.25"
    y="102.5"
    width="47.25"
    height="147.5"
    stroke-width="1"
    filter="">
    </rect>
    <rect stroke="rgba(0,0,0,0)"
    fill="#5cf"
    x="532.75"
    y="82.5"
    width="47.25"
    height="167.5"
    stroke-width="1"
    filter="">
    </rect>
    <rect stroke="rgba(0,0,0,0)"
    fill="#5cf"
    x="585.25"
    y="25.0"
    width="47.25"
    height="225.0"
    stroke-width="1"
    filter="">
    </rect>
    <rect stroke="rgba(0,0,0,0)"
    fill="#5cf"
    x="637.75"
    y="165.0"
    width="47.25"
    height="85.0"
    stroke-width="1"
    filter="">
    </rect>
    </g>
    </svg>
    


