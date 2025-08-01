defmodule Matplotex.MixProject do
  use Mix.Project

  def project do
    [
      app: :matplotex,
      organization: :bigthinkcode,
      version: "0.4.8",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package()
    ]
  end

  defp package do
    [
      description: "A library for generating plots in Elixir.",
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/bigthinkcode/matplotex"
      },
      maintainers: ["BigThinkCode", "Mohammed Sadique P", "Karthikeyan Mayilvahanam"]
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths(:dev) ++ ["test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:csv, "~> 3.2"},
      {:nx, "~> 0.7.3"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:rustler, "~> 0.36.2"},
      {:rustler_precompiled, "~> 0.8.2"}
    ]
  end
end
