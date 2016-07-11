defmodule EctoStateMachine.TestFactory do
  use ExMachina.Ecto, repo: EctoStateMachine.TestRepo
  alias EctoStateMachine.{User, UserWithInitial}

  def user_factory do
    %User{
      state: "started",
    }
  end

  def user_with_initial_factory do
    %UserWithInitial{
      state: "",
    }
  end
end
