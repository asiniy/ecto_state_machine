defmodule EctoStateMachine.Mixfile do
  use Mix.Project

  @project_url "https://github.com/asiniy/ecto_state_machine"
  @version     "0.1.0"

  def project do
    [
      app: :ecto_state_machine,
      version: @version,
      elixir: "~> 1.2",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      source_url: @project_url,
      homepage_url: @project_url,
      description: "State machine pattern for Ecto. I tried to make it similar as possible to ruby's gem 'aasm'",
      package: package
   ]
  end

  defp elixirc_paths(:test), do: elixirc_paths ++ ["test/support", "test/dummy"]
  defp elixirc_paths(_), do: elixirc_paths
  defp elixirc_paths, do: ["lib"]

  def application do
    [
      applications: app_list(Mix.env),
    ]
  end

  def app_list(:test), do: app_list ++ [:ecto, :postgrex, :ex_machina]
  def app_list(_), do: app_list
  def app_list, do: [:logger]

  defp deps do
    [
     {:ecto, ">= 1.1.2 or >= 2.0.0"},

     {:postgrex,   ">= 0.0.0", only: :test},
     {:ex_machina, "~> 1.0.0-beta1", github: "thoughtbot/ex_machina", only: :test},
     {:ex_spec,    "~> 1.1.0 or ~> 2.0.0", only: :test}
    ]
  end

  defp package do
    [
      name: :ecto_state_machine,
      files: ["lib/ecto_state_machine.ex", "mix.exs"],
      maintainers: ["Alex Antonov"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub"        => @project_url,
        "Author's blog" => "http://asiniy.github.io/"
      }
    ]
  end
end
