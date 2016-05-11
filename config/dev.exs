use Mix.Config

# Configure your database
config :ecto_state_machine, EctoStateMachine.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("USER"),
  password: "posgtres",
  database: "ecto_state_machine_development",
  pool_size: 10,
  port: 5432
