defmodule TrainLoc.Mixfile do
  use Mix.Project

  def project do
    [
      app: :trainloc,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      dialyzer: [ignore_warnings: "dialyzer.ignore-warnings"]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      extra_applications: [
        :goth,
        :logger
      ],
      mod: {TrainLoc, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/integration"]
  defp elixirc_paths(_), do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:distillery, "~> 1.5", runtime: false},
      {:ehmon, git: "https://github.com/heroku/ehmon.git", tag: "v4", only: :prod},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:excoveralls, "~> 0.8", only: :test},
      {:goth, "~> 0.7"},
      {:hackney, "== 1.10.1"},
      {:poison, "~> 3.1"},
      {:timex, "~> 3.1.24"}
    ]
  end
end