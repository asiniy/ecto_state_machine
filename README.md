# Ecto state machine

This package allows to use [finite state machine pattern](https://en.wikipedia.org/wiki/Finite-state_machine) in Ecto. Specify:

* states
* events
* transitions
* repo

and go:

``` elixir
defmodule Dummy.User do
  use Dummy.Web, :model

  use EctoStateMachine,
    states: [:unconfirmed, :confirmed, :blocked, :admin],
    events: [
      [
        name:     :confirm,
        from:     [:unconfirmed],
        to:       :confirmed,
        callback: fn(model) -> Ecto.Changeset.change(model, confirmed_at: Ecto.DateTime.utc) end # yeah you can bring your own code to these functions.
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
  repo: Dummy.Repo

  schema "users" do
    field :state, :string
  end
end
```

now you can run:

``` elixir
user     = Dummy.Repo.get_by(Dummy.User, id: 1)
new_user = Dummy.User.confirm(user)  # => transition user state to "confirmed". We can make him admin!
Dummy.User.can_confirm?(new_user)    # => false
Dummy.User.can_make_admin?(new_user) # => true
Dummy.User.make_admin(new_user)
```

You can check out whole `test/dummy` directory to inspect how to organize sample app.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add ecto_state_machine to your list of dependencies in `mix.exs`:

        def deps do
          [{:ecto_state_machine, "~> 0.0.4"}]
        end

  2. Ensure ecto_state_machine is started before your application:

        def application do
          [applications: [:ecto_state_machine]]
        end

## Contributions

1. Install dependencies `mix deps.get`
1. Setup your `config/test.exs` & `config/dev.exs`
1. Run migrations `mix ecto.migrate` & `MIX_ENV=test mix ecto.migrate`
1. Develop new feature
1. Write new tests
1. Test it: `mix test`
1. Open new PR!

## TODOs

- [x] Cover by tests
- [ ] Custom db column name
- [ ] Validation method for changeset indicates its value in the correct range
- [ ] Initial value
- [ ] CI
- [ ] Add status? methods
- [x] Introduce it at elixir-radar and my blog
