defmodule EctoStateMachine do
  defmacro __using__(opts) do
    column = Keyword.get(opts, :column, :state)
    sm_states = Keyword.get(opts, :states)

    cast_fn =
      opts
      |> Keyword.get(:cast_fn, quote do: &("#{&1}"))
      |> Macro.escape()

    load_fn =
      opts
      |> Keyword.get(:load_fn, quote do: &(:"#{&1}"))
      |> Macro.escape()

    events = Keyword.get(opts, :events)
      |> Enum.map(fn(event) ->
        Keyword.put_new(event, :callback, quote do: fn(model) -> model end)
      end)
      |> Enum.map(fn(event) ->
        Keyword.update!(event, :callback, &Macro.escape/1)
      end)

    function_prefix = if column == :state, do: nil, else: "#{column}_"

    quote bind_quoted: [
      sm_states: sm_states,
      events: events,
      column: column,
      function_prefix: function_prefix,
      cast_fn: cast_fn,
      load_fn: load_fn
    ] do

      alias Ecto.Changeset

      def unquote(:"#{function_prefix}states")() do
        unquote(sm_states)
      end

      def unquote(:"#{function_prefix}events")() do
        unquote(events) |> Enum.map(fn(x) -> x[:name] end)
      end

      events
      |> Enum.each(fn(event) ->
        unless event[:to] in sm_states do
          raise "Target state :#{event[:to]} is not present in ecto_state_machine definition states"
        end

        def unquote(event[:name])(model) do
          casted = unquote(cast_fn).(unquote(event[:to]))

          model
          |> Changeset.change(%{ unquote(column) => casted })
          |> unquote(event[:callback]).()
          |> validate_state_transition(unquote(event), model)
        end

        def unquote(:"can_#{event[:name]}?")(model) do
          loaded =
            model
            |> Map.get(unquote(column))
            |> unquote(load_fn).()

          loaded in unquote(event[:from])
        end
      end)

      defp validate_state_transition(changeset, event, model) do
        loaded =
          model
          |> Map.get(unquote(column))
          |> unquote(load_fn).()

        if loaded in event[:from] do
          changeset
        else
          changeset
          |> Changeset.add_error(unquote(column),
            "You can't move state from :#{loaded} to :#{event[:to]}"
            )
        end
      end
    end
  end
end
