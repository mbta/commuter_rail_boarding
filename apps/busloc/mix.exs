defmodule Busloc.MixProject do
  use Mix.Project

  def project do
    [
      app: :busloc,
      build_path: "../../_build",
      config_path: "config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Busloc, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:httpoison, "~> 1.0"},
      {:jason, "~> 1.1.1"},
      {:sweet_xml, "~> 0.6"},
      {:timex, "3.4.1"},
      {:fast_local_datetime, "~> 0.3"},
      {:xml_builder, "~> 2.1", override: true},
      {:plug, "~> 1.5"},
      {:logger_splunk_backend,
       github: "mbta/logger_splunk_backend", branch: "master", only: :prod},
      {:bypass, "~> 0.8", only: :test}
    ]
  end
end
