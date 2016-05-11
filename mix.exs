defmodule EctoStateMachine.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ecto_state_machine,
      version: "0.0.1",
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,

      description: "State machine pattern for Ecto. I tried to make it similar as possible to ruby's gem 'aasm'",
      package: package
   ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
     {:ecto, "~> 1.0.0"},

     {:postgrex, ">= 0.0.0", only: :test},
     {:ex_machina, "~> 0.6.1", only: :test},
     {:ex_spec, "~> 1.0.0", only: :test}
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
