defmodule Conserva.ConvertTask.RepoInteraction do
  import Ecto.Query
  alias Conserva.{Repo, ConvertTask}

  def get_by_id(id) do
    Repo.one(from key in ConvertTask,
             where: key.id == ^id, preload: [:api_key])
  end

  def get_info_by_id(id) do
    Repo.one(from key in ConvertTask,
             where: key.id == ^id,
             select: %{id: key.id,
                       state: key.state,
                       source_filename: key.source_filename,
                       result_filename: key.result_filename,
                       input_extension: key.output_extension,
                       output_extension: key.output_extension,
                       created_at: key.created_at,
                       updated_at: key.updated_at,
                       finished_at: key.finished_at,
                       errors: key.errors,
                       source_file_sha256: key.source_file_sha256,
                       result_file_sha256: key.result_file_sha256})
  end

  def get_info_for_download_by_id(id) do
    Repo.one(from key in ConvertTask,
             where: key.id == ^id,
             select: %{state: key.state,
                       filename: key.source_filename})
  end

  def create_new_task(raw_task) do
    inserted_task = Map.put(raw_task, :created_at, Ecto.DateTime.from_erl(:calendar.universal_time())) |> Map.put(:state, "received")
    Repo.insert(inserted_task)
  end

  def delete(task) do
    Repo.delete(task)
  end
end
