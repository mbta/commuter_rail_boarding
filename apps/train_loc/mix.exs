defmodule TrainLoc.Mixfile do
  use Mix.Project

  def project do
    [
      app: :train_loc,
      version: "0.1.0",
      elixir: "~> 1.8log_",
      elixirc_paths: elixirc_paths(Mix.env()),
      config_path: "config/config.exs",
      build_path: "../../_build",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
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
      {:distillery, "~> 2.0", runtime: false},
      {:ehmon, git: "https://github.com/mbta/ehmon.git", tag: "master", only: :prod},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:excoveralls, "~> 0.8", only: :test},
      {:goth, "~> 1.0"},
      {:poison, "~> 4.0"},
      {:timex, "~> 3.6.1"}
    ]
  end
end
