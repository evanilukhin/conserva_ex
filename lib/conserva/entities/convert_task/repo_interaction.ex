defmodule Conserva.ConvertTask.RepoInteraction do
  import Ecto.Query
  alias Conserva.{Repo, ConvertTask}

  def get_convert_task_by_id(id) do
    Repo.one(from key in ConvertTask, where: key.id == ^id)
  end

  def get_task_info_by_id(id) do
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
                       result_file_sha256: key.result_file_sha256,
                       errors: key.errors,
                     })
  end
end
