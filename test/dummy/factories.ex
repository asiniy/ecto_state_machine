defmodule Dummy.Factories do
  use ExMachina.Ecto, repo: Dummy.Repo

  def user_factory do
    %Dummy.User{
      rules: "started"
    }
  end
end
