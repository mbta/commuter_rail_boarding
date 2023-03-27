defmodule Shared.MixProject do
  use Mix.Project

  def project do
    [
      app: :shared,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      config_path: "../../config/config.exs",
      build_path: "../../_build",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: LcovEx]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/integration"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
    ]
  end
end
