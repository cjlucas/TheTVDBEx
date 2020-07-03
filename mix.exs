defmodule TheTVDB.Mixfile do
  use Mix.Project

  def project do
    [app: :thetvdb,
     version: "1.1.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     consolidate_protocols: Mix.env != :test
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [applications: [:logger, :httpoison], mod: {TheTVDB, []}]
  end

  def description do
    """
    An Elixir library for TheTVDB API
    """
  end

  def package do
    [
      name: :thetvdb,
      licenses: ["MIT"],
      maintainers: ["Chris Lucas <chris@chrisjlucas.com>"],
      links: %{"GitHub" => "https://github.com/cjlucas/TheTVDBEx"}
    ]
  end

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
      {:httpoison, "~> 0.11"},
      {:poison, "~> 3.1"},
      {:timex, "~> 3.1"},
      {:bypass, "~> 0.6", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
