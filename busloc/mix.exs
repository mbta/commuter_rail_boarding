defmodule Busloc.MixProject do
  use Mix.Project

  def project do
    [
      app: :busloc,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:timex, "~> 3.2"},
      {:xml_builder, "~> 2.1", override: true}
    ]
  end
end
