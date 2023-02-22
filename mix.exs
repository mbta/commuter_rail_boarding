defmodule LocUmbrella.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "1.0.0",
      aliases: aliases(),
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/mbta/commuter_rail_boarding",
      test_coverage: [tool: LcovEx],
      dialyzer: [
        plt_add_deps: :app_tree,
        flags: [:unmatched_returns],
        ignore_warnings: "dialyzer.ignore-warnings"
      ],
      releases: releases()
    ]
  end

  defp releases do
    [
      commuter_rail_boarding: [
        applications: [
          runtime_tools: :permanent,
          commuter_rail_boarding: :permanent,
          train_loc: :permanent,
          ex_aws: :permanent,
          hackney: :permanent
        ]
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
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
