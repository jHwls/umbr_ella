defmodule UmbrElla.MixProject do
  use Mix.Project

  @version "0.1.0"
  @repo_url "https://github.com/jhwls/umbr_ella"

  def project do
    [
      app: :umbr_ella,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Hex
      description: "Conveniences for working with Elixir umbrella projects 🌂",
      package: [
        maintainers: ["J Howells"],
        licenses: ["Apache-2.0"],
        links: %{"GitHub" => @repo_url}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:excoveralls, "~> 0.17", only: [:test], runtime: false}
    ]
  end
end
