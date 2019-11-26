defmodule CommuterRailBoarding.Mixfile do
  use Mix.Project

  def project do
    [
      app: :commuter_rail_boarding,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [{:"coveralls.html", :test}]
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
      {:poison, "~> 4.0"},
      {:httpoison, "~> 1.5"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:gen_stage, "~> 0.14.1"},
      {:tzdata, "~> 1.0-pre"},
      {:jason, "~> 1.0"},
      {:server_sent_event_stage, "~> 0.4"},
      {:excoveralls, "~> 0.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:bypass, "~> 1.0", only: :test},
      {:distillery, "~> 2.0", runtime: false},
      {:ehmon,
       git: "https://github.com/mbta/ehmon.git", tag: "master", only: :prod}
    ]
  end

  defp aliases do
    [
      start: "run --no-halt"
    ]
  end
end
