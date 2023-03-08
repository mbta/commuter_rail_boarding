defmodule CommuterRailBoarding.Mixfile do
  use Mix.Project

  def project do
    [
      app: :commuter_rail_boarding,
      version: "0.1.0",
      elixir: "~> 1.8",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: LcovEx]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/uploader"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :joken],
      mod: {CommuterRailBoarding.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:goth, "~> 1.0"},
      {:httpoison, "~> 2.0"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:gen_stage, "~> 1.0"},
      {:tzdata, "~> 1.0-pre"},
      {:jason, "~> 1.1"},
      {:server_sent_event_stage, "~> 1.0"},
      {:castore, "~> 0.1"},
      {:lcov_ex, "~> 0.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:bypass, "~> 2.1", only: :test},
      {:ehmon, git: "https://github.com/mbta/ehmon.git", tag: "master", only: :prod}
    ]
  end

  defp aliases do
    [
      start: "run --no-halt"
    ]
  end
end
