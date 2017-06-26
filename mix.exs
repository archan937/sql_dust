defmodule SqlDust.Mixfile do
  use Mix.Project

  def project do
    [app: :sql_dust,
     version: "0.4.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     elixirc_paths: elixirc_paths(Mix.env),
     aliases: aliases()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:inflex, "~> 1.6.0"},
      {:ecto, ">= 1.1.0", optional: true},
      {:exprof, "~> 0.2.0", only: :dev},
      {:benchfella, "~> 0.3.0", only: :dev},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:credo, "~> 0.2", only: [:dev, :test]},
      {:inch_ex, ">= 0.0.0", only: :docs},
      {:db_connection, ">= 0.0.0", only: :test},
      {:mariaex, ">= 0.0.0", only: :test}
    ]
  end

  defp description do
    """
    Easy. Simple. Powerful. Generate (complex) SQL queries using magical Elixir SQL dust.
    """
  end

  defp package do
    [
      maintainers: ["Paul Engel", "Daniel Willemse", "Peter Arentsen"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/bettyblocks/sql_dust"}
    ]
  end

  defp elixirc_paths(:test), do: ~w(lib test/support)
  defp elixirc_paths(_), do: ~w(lib)

  defp aliases do
    ["test": ["ecto.create --quiet", "ecto.migrate --quiet", "test"]]
  end

end
