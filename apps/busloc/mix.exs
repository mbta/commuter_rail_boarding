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
      test_coverage: [tool: ExCoveralls]
    ]
  end

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
      {:sweet_xml, "~> 0.6"},
      {:timex, "~> 3.1"},
      {:xml_builder, "~> 2.1", override: true},
      {:logger_splunk_backend, github: "mbta/logger_splunk_backend", only: :prod}
    ]
  end
end
