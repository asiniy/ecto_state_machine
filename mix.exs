defmodule EctoStateMachine.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecto_state_machine,
      version: "0.0.2",
      elixir: "~> 1.2",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,

      description: "State machine pattern for Ecto. I tried to make it similar as possible to ruby's gem 'aasm'",
      package: package
   ]
  end

  defp elixirc_paths(:prod), do: ["lib"]
  defp elixirc_paths(:dev),  do: ["lib", "test/dummy/web", "test/dummy/lib"]
  defp elixirc_paths(:test), do: ["lib", "test"]

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
     {:ecto, "2.0.0-rc.5"},

     {:postgrex,   ">= 0.0.0", only: :test},
     {:ex_machina, "~> 1.0.0-beta.1", github: "thoughtbot/ex_machina", only: :test},
     {:ex_spec,    "~> 1.0.0", only: :test}
    ]
  end

  defp package do
    [
      name: :ecto_state_machine,
      files: ["lib/ecto_state_machine.ex", "mix.exs"],
      maintainers: ["Alex Antonov"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub"        => "https://github.com/asiniy/ecto_state_machine",
        "Author's blog" => "http://asiniy.github.io/"
      }
    ]
  end
end
