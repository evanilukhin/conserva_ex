defmodule Conserva.Repo.Migrations.CreateApiKeys do
  use Ecto.Migration

  def change do
    create table(:api_keys) do
      add :uuid, :uuid
      add :name, :string
      add :comment, :string
    end
  end
end
