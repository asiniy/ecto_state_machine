defmodule EctoStateMachine do
  defmacro __using__(opts) do
    repo   = Keyword.get(opts, :repo)
    states = Keyword.get(opts, :states)
    initial = Keyword.get(opts, :initial)
    events = Keyword.get(opts, :events)
      |> Enum.map(fn(event) ->
        Keyword.put_new(event, :callback, quote do: fn(model) -> model end)
      end)
      |> Enum.map(fn(event) ->
        Keyword.update!(event, :callback, &Macro.escape/1)
      end)

    quote bind_quoted: [states: states, events: events, repo: repo, initial: initial] do
      events
      |> Enum.each(fn(event) ->
        unless event[:to] in states do
          raise "Target state :#{event[:to]} is not present in @states"
        end

        def unquote(event[:name])(model) do
          validate_state_model(model, unquote(event))

          model
          |> Ecto.Changeset.cast(%{ state: "#{unquote(event[:to])}" }, ~w(state), ~w())
          |> unquote(event[:callback]).()
        end

        def unquote(:"#{event[:name]}!")(model) do
          { :ok, new_model } =
            unquote(event[:name])(model)
            |> unquote(repo).update

          new_model
        end

        def unquote(:"can_#{event[:name]}?")(model) do
          :"#{state_with_initial(model.state)}" in unquote(event[:from])
        end
      end)

      states
      |> Enum.each(fn(state) ->
        def unquote(:"#{state}?")(model) do
          :"#{state_with_initial(model.state)}" == unquote(state)
        end
      end)

      defp unquote(:validate_state_model)(%Ecto.Changeset{} = cs, event) do
        case cs do
          %{ data:  model } -> _validate_state_field(model, event)
          %{ model: model } -> _validate_state_field(model, event)
        end
      end
      defp unquote(:validate_state_model)(model, event), do: _validate_state_field(model, event)

      defp unquote(:_validate_state_field)(model, event) do
        state = state_with_initial(model.state)
        unless :"#{state}" in event[:from] do
          raise RuntimeError, "You can't move state from :#{state || "nil"} to :#{event[:to]}"
        end
      end

      def unquote(:state)(model) do
        "#{state_with_initial(model.state)}"
      end

      defp state_with_initial(state) do
        if :"#{state}" in unquote(states) do
          state
        else
          unquote(initial)
        end
      end
    end
  end
end
