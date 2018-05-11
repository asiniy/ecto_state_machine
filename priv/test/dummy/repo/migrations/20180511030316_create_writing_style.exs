defmodule Dummy.Repo.Migrations.CreateWritingStyle do
  use Ecto.Migration

  def change do
    create table(:writing_styles) do
      add :state, :string
    end
  end
end
