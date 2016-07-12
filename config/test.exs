use Mix.Config

# Configure your database
config :ecto_state_machine, EctoStateMachine.TestRepo,
  hostname: "localhost",
  database: "ecto_state_machine_test",
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warn
