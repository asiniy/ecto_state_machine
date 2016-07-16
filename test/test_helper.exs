Mix.Task.run "ecto.drop",    ["quiet", "-r", "Dummy.Repo"]
Mix.Task.run "ecto.create",  ["quiet", "-r", "Dummy.Repo"]
Mix.Task.run "ecto.migrate", ["-r", "Dummy.Repo"]

ExUnit.start()

{ :ok, _ } = Dummy.Repo.start_link
