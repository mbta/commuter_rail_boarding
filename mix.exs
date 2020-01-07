defmodule LocUmbrella.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      aliases: aliases(),
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/mbta/commuter_rail_boarding",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      dialyzer: [
        plt_add_deps: :transitive,
        flags: [
          :race_conditions,
          :unmatched_returns
        ],
        ignore_warnings: "dialyzer.ignore-warnings"
      ]
    ]
  end

  defp aliases do
    [compile: ["compile --warnings-as-errors"]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end
end
