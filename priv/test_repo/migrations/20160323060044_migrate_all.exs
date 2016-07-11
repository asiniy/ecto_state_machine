defmodule EctoStateMachine.TestRepo.Migrations.MigrateAll do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :state, :string, null: false
      add :confirmed_at, :datetime
    end
  end
end
