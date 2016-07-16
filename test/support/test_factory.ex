defmodule EctoStateMachine.TestFactory do
  use ExMachina.Ecto, repo: EctoStateMachine.TestRepo
  alias EctoStateMachine.User

  def user_factory do
    %User{
      state: "started",
    }
  end
end
