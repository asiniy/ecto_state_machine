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
