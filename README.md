# Ecto state machine

![travis ci badge](https://travis-ci.org/asiniy/ecto_state_machine.svg)
![badge](https://img.shields.io/hexpm/v/ecto_state_machine.svg)

This package allows to use [finite state machine pattern](https://en.wikipedia.org/wiki/Finite-state_machine) in Ecto. Specify:

* states
* events
* column ([optional](#custom-column-name))

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
    ]

  schema "users" do
    field :state, :string, default: "unconfirmed"
  end
end
```

now you can run:

``` elixir
user     = Dummy.Repo.get_by(Dummy.User, id: 1)

confirmed_user = Dummy.User.confirm(user)     # => transition user state to "confirmed". We can make him admin!
Dummy.User.can_confirm?(confirmed_user)       # => false
Dummy.User.can_make_admin?(confirmed_user)    # => true
admin = Dummy.User.make_admin(confirmed_user) # => transition user state to "admin"

Dummy.Repo.update(admin)                      # => store user to the database
```

You can check out whole `test/dummy` directory to inspect how to organize sample app.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add ecto_state_machine to your list of dependencies in `mix.exs`:

        def deps do
          [{:ecto_state_machine, "~> 0.1.0"}]
        end

### Custom column name

`ecto_state_machine` uses `state` database column by default. You can specify
`column` option to change it. Like this:

``` elixir
defmodule Dummy.User do
  use Dummy.Web, :model

  use EctoStateMachine,
    column: :rules,
    # bla-bla-bla
end
```

Now your state will be stored into `rules` column.

## Contributions

1. Install dependencies `mix deps.get`
1. Setup your `config/test.exs` & `config/dev.exs`
1. Run migrations `mix ecto.migrate` & `MIX_ENV=test mix ecto.migrate`
1. Develop new feature
1. Write new tests
1. Test it: `mix test`
1. Open new PR!

## Roadmap to 1.0

- [x] Cover by tests
- [x] Custom db column name
- [x] Validation method for changeset indicates its value in the correct range
- [x] Initial value
- [x] CI
- [x] Add status? methods
- [ ] Introduce it at elixir-radar and my blog
- [ ] Custom error messages for changeset (with translations by gettext ability)
- [x] Rely on last versions of ecto & elixir
- [ ] Write dedicated module instead of requiring everything into the model
- [ ] Write bang! methods which are raising exception instead of returning invalid changeset
