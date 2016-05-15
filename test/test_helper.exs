ExUnit.start()

{ :ok, _ } = Dummy.Repo.start_link
{ :ok, _ } = Application.ensure_all_started(:postgrex)
{ :ok, _ } = Application.ensure_all_started(:ex_machina)
