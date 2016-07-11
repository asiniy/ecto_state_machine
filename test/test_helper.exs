Mix.Task.run "ecto.drop", ["quiet", "-r", "EctoStateMachine.TestRepo"]
Mix.Task.run "ecto.create", ["quiet", "-r", "EctoStateMachine.TestRepo"]
Mix.Task.run "ecto.migrate", ["-r", "EctoStateMachine.TestRepo"]

{:ok, _} = EctoStateMachine.TestRepo.start_link
ExUnit.start()
