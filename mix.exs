defmodule Battleship.MixProject do
  use Mix.Project

  def project do
    [
      app: :battleship,
      version: "0.1.0",
      elixir: "~> 1.6",
      # compilers: [:phoenix] ++ Mix.compilers,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  defp escript do
    [main_module: Battleship.CLI]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Battleship, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.3.2"},
      {:cowboy, "~> 1.0"},
      {:behavior_tree, "~> 0.3.0"},
      {:uuid, "~> 1.1"},
      {:cors_plug, "~> 1.5"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
