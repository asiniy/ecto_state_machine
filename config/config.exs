use Mix.Config

import_config "#{Mix.env}.exs"

config :ecto_state_machine,
  ecto_repos: [Dummy.Repo]
