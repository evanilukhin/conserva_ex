defmodule Conserva.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :state, :string
      add :source_filename, :string
      add :result_filename, :string
    end
  end
end
