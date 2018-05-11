# Ecto state machine

![travis ci badge](https://travis-ci.org/asiniy/ecto_state_machine.svg)
![badge](https://img.shields.io/hexpm/v/ecto_state_machine.svg)

This package allows to use [finite state machine pattern](https://en.wikipedia.org/wiki/Finite-state_machine) in Ecto. Specify:

* states
* events
* column ([optional](#custom-column-name))

and go:

``` elixir
defmodule User do
  use Web, :model

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

now you can do:

``` elixir
user = Repo.get_by(User, id: 1)

# Create changeset transition user state to "confirmed". We can make him admin!
confirmed_user = User.confirm(user)     # =>

# We can validate ability to change user's state
User.can_confirm?(confirmed_user)       # => false
User.can_make_admin?(confirmed_user)    # => true

# Create changeset transition user state to "admin"
admin = User.make_admin(confirmed_user)

# Store changeset to the database
Repo.update(admin)


# List all possible states
# If column isn't `:state`, function name will be prefixed. IE,
# for column `:rules` function name will be `rules_states`
User.states # => [:unconfirmed, :confirmed, :blocked, :admin]

# List all possible events
# If column isn't `:state`, function name will be prefixed. IE,
# for column `:rules` function name will be `rules_events`
User.events # => [:confirm, :block, :make_admin]
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

### Custom mapping between state name and field value

By default, the atomic state names are stringified when generating the changeset. However, there are situations where the underlying Ecto schema value isn't simply a stringified version of the state name. You can customize the mapping by passing cast/load functions like so:

```elixir
defmodule Dummy.WritingStyle do
  use Dummy.Web, :model

  use EctoStateMachine,
    states: [:upcased, :camel_cased],
    cast_fn: fn
      :upcased -> "UPCASED"
      :camel_cased -> "camelCased"
    end,
    load_fn: fn
      "UPCASED" -> :upcased
      "camelCased" -> :camel_cased
    end,
    events: [
      [
        name: :upcase,
        from: [:camel_cased],
        to: :upcased
      ],
      [
        name: :camel_case,
        from: [:upcased],
        to: :camel_cased
      ]
    ]

  schema "writing_styles" do
    field :state, :string
  end
end
```

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
- [ ] Rewrite spaghetti description in README
