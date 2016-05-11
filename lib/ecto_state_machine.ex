defmodule EctoStateMachine do
  defmacro __using__(opts) do
    states = Keyword.get(opts, :states)
    events = Keyword.get(opts, :events)
      |> Enum.map(fn(event) ->
        Keyword.put_new(event, :callback, quote do: fn(model) -> model end)
      end)
      |> Enum.map(fn(event) ->
        Keyword.update!(event, :callback, &Macro.escape/1)
      end)

    quote bind_quoted: [states: states, events: events] do
      import Ecto.Changeset, only: [cast: 4]

      events
      |> Enum.each(fn(event) ->
        unless event[:to] in states do
          raise "Target state :#{event[:to]} is not present in @states"
        end

        def unquote(event[:name])(model) do
          unless :"#{model.state}" in unquote(event[:from]) do
            raise "You can't move state from :#{model.state} to :#{unquote(event[:to])}"
          end

          model
          |> cast(%{ state: "#{unquote(event[:to])}" }, ~w(state), ~w())
          |> unquote(event[:callback]).()
          |> Oblako.Repo.update
        end

        def unquote(:"can_#{event[:name]}?")(model) do
          :"#{model.state}" in unquote(event[:from])
        end
      end)
    end
  end
end
