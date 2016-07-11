defmodule EctoStateMachine.UserWithInitial do
  use Ecto.Schema

  use EctoStateMachine,
    states: [:unconfirmed, :confirmed, :blocked, :admin],
    initial: :admin,
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
  end
end
