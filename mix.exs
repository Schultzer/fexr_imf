defmodule FexrImf.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :fexr_imf,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      # Hex
      description: description(),
      package: package(),

      #Docs
      name: "FexrImf",
      docs: [source_ref: "v#{@version}",
       main: "FexrYahoo",
       canonical: "http://hexdocs.pm/fexr_imf",
       source_url: "https://github.com/schultzer/fexr_imf",
       description: "FexrImf serve you historical exchange rates from [https://www.imf.org](IMF) in a simple developer friendly map."]

    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {FexrImf.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 0.12"},
      {:floki, "~> 0.17.2"},
      {:con_cache, "~> 0.12.0"}
    ]
  end

  defp description do
  """
  FexrImf serve you historical exchange rates from [https://www.imf.org](IMF) in a simple developer friendly map.
  """
  end

  defp package do
    [name: :fexr_imf,
     maintainers: ["Benjamin Schultzer"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/schultzer/fexr_imf",
              "Docs" => "https://hexdocs.pm/fexr_imf"},
     files: ~w(lib) ++
            ~w(mix.exs README.md LICENSE mix.exs)]
  end

end
