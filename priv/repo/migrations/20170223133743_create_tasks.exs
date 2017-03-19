defmodule Conserva.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:convert_tasks) do
      add :state, :string
      add :source_filename, :string
      add :result_filename, :string
      add :source_file, :string
      add :converted_file, :string
      add :input_extension, :string
      add :output_extension, :string
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
      add :finished_at, :utc_datetime
      add :errors, :text
      add :source_file_sha256, :string, size: 64
      add :result_file_sha256, :string, size: 64
      add :downloads_count, :integer, default: 0
      add :last_download_time, :utc_datetime
    end
  end
end
