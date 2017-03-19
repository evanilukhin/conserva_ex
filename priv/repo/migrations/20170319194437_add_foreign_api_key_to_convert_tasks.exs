defmodule Conserva.Repo.Migrations.AddForeignApiKeyToConvertTasks do
  use Ecto.Migration

  def change do
    alter table(:convert_tasks) do
      add :api_key_id, references(:api_keys)
    end
  end
end
