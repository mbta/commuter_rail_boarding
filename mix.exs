defmodule CommuterRailBoarding.Mixfile do
  use Mix.Project

  def project do
    [
      app: :commuter_rail_boarding,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:goth, "~> 0.5.0"},
      {:httpoison, "~> 0.12"}
    ]
  end
end
