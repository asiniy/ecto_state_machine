defmodule EctoStateMachine.EctoCase do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoStateMachine.TestRepo)
  end
end
