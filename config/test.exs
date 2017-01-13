use Mix.Config

# Configure your database
config :ecto_state_machine, Dummy.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER") || "postgres" ,
  password: System.get_env("DB_PASS") || "",
  database: "ecto_state_machine_test",
  pool_size: 10,
  port: 5432,
  priv: "priv/test/dummy/repo/"
