defmodule Conserva.Mixfile do
  use Mix.Project

  def project do
    [app: :conserva,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Conserva.Application, []}
    ]
  end
  defp deps do
    [
      {:ecto, "~> 2.1"},
      {:postgrex, "~> 0.13.1"},
      {:logger_file_backend, "~> 0.0.10"},
      {:plug, "~> 1.0"},
      {:cowboy, "~> 1.0.0"},
      {:poison, "~> 3.0"},
      {:yaml_elixir, "~> 1.3"},
      {:timex, "~> 3.0"}
    ]
  end
end
