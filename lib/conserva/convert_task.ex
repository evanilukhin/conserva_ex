defmodule Conserva.ConvertTask do
  use Ecto.Schema

  schema "convert_tasks" do
    field :state, :string
    field :source_filename, :string
    field :result_filename, :string
    field :source_file, :string
    field :converted_file, :string
    field :input_extension, :string
    field :output_extension, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
    field :finished_at, :utc_datetime
    field :errors, :string
    field :source_file_sha256, :string, size: 64
    field :result_file_sha256, :string, size: 64
    field :downloads_count, :integer, default: 0
    field :last_download_time, :utc_datetime
    belongs_to :api_key, Conserva.ApiKey
  end
end
