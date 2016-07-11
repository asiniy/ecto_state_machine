defmodule EctoStateMachine do
  defmacro __using__(opts) do
    repo   = Keyword.get(opts, :repo)
    states = Keyword.get(opts, :states)
    events = Keyword.get(opts, :events)
      |> Enum.map(fn(event) ->
        Keyword.put_new(event, :callback, quote do: fn(model) -> model end)
      end)
      |> Enum.map(fn(event) ->
        Keyword.update!(event, :callback, &Macro.escape/1)
      end)

    quote bind_quoted: [states: states, events: events, repo: repo] do
      events
      |> Enum.each(fn(event) ->
        unless event[:to] in states do
          raise "Target state :#{event[:to]} is not present in @states"
        end

        def unquote(event[:name])(model) do
          unless :"#{model.state}" in unquote(event[:from]) do
            raise RuntimeError, "You can't move state from :#{model.state} to :#{unquote(event[:to])}"
          end

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
          :"#{model.state}" in unquote(event[:from])
        end
      end)
    end
  end
end
