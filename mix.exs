defmodule Deribit.MixProject do
  use Mix.Project

  def project do
    [
      app: :deribit,
      version: "0.2.3",
      elixir: "~> 1.9.1",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Deribit",
      description: " Deribit v2 WebSockets API client for Elixir",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README*),
      licenses: ["Apache 2.0"],
      links: %{}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.1"},
      {:socket, "~> 0.3.13"},
      {:websockex, "~> 0.4.3"}
    ]
  end
end
