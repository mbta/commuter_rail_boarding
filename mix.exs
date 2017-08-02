defmodule CommuterRailBoarding.Mixfile do
  use Mix.Project

  def project do
    [
      app: :commuter_rail_boarding,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [{:"coveralls.html", :test}]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/uploader"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {CommuterRailBoarding.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:goth, "~> 0.5"},
      {:httpoison, "~> 0.12"},
      {:ex_aws, "~> 1.1"},
      {:gen_stage, "~> 0.12"},
      {:excoveralls, "~> 0.7", only: [:dev, :test]}
    ]
  end
end
