defmodule EctoStateMachine.User do
  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 4]

  @required_params ~w()
  @optional_params ~w(state confirmed_at)

  use EctoStateMachine,
    states: [:unconfirmed, :confirmed, :blocked, :admin],
    events: [
      [
        name:     :confirm,
        from:     [:unconfirmed],
        to:       :confirmed,
        callback: fn(model) -> Ecto.Changeset.change(model, confirmed_at: Ecto.DateTime.utc) end
      ], [
        name:     :block,
        from:     [:confirmed, :admin],
        to:       :blocked
      ], [
        name:     :make_admin,
        from:     [:confirmed],
        to:       :admin
      ]
    ],
    repo: EctoStateMachine.TestRepo

  schema "users" do
    field :state, :string
    field :confirmed_at, Ecto.DateTime
  end

  def changeset(user, params \\ :empty) do
    user
    |> cast(params, @required_params, @optional_params)
  end
end
