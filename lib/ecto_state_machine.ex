defmodule EctoStateMachine do
  defmacro __using__(opts) do
    column = Keyword.get(opts, :column, :state)
    states = Keyword.get(opts, :states)
    events = Keyword.get(opts, :events)
      |> Enum.map(fn(event) ->
        Keyword.put_new(event, :callback, quote do: fn(model) -> model end)
      end)
      |> Enum.map(fn(event) ->
        Keyword.update!(event, :callback, &Macro.escape/1)
      end)

    quote bind_quoted: [states: states, events: events, column: column] do
      alias Ecto.Changeset

      events
      |> Enum.each(fn(event) ->
        unless event[:to] in states do
          raise "Target state :#{event[:to]} is not present in @states"
        end

        def unquote(event[:name])(model) do
          model
          |> Changeset.change(%{ unquote(column) => "#{unquote(event[:to])}" })
          |> unquote(event[:callback]).()
          |> validate_state_transition(unquote(event), model)
        end

        def unquote(:"can_#{event[:name]}?")(model) do
          :"#{Map.get(model, unquote(column))}" in unquote(event[:from])
        end
      end)

      defp validate_state_transition(changeset, event, model) do
        change = Map.get(model, unquote(column))

        if :"#{change}" in event[:from] do
          changeset
        else
          changeset
          |> Changeset.add_error(unquote(column),
            "You can't move state from :#{change} to :#{event[:to]}"
            )
        end
      end
    end
  end
end
