defmodule Dummy.Repo do
  use Ecto.Repo, otp_app: :ecto_state_machine, adapter: Ecto.Adapters.Postgres
end
