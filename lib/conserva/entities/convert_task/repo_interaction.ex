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
    inserted_task = Map.merge(raw_task, %{created_at: Ecto.DateTime.utc,
                                          state: "received"})
    Repo.insert(inserted_task)
  end

  def get_unconverted_tasks(created_at_order \\ :asc) do
    query =
      from task in ConvertTask,
        where: task.state != "finished",
        order_by: [{^created_at_order, task.created_at}]
    Repo.all(query)
  end

  def get_unconverted_tasks_for_converter(converter, created_at_order \\ :asc) do
    query =
      from task in ConvertTask,
        where: task.state != "finished" and
               task.input_extension in ^converter.from_ext and
               task.output_extension in ^converter.to_ext,
        order_by: [{^created_at_order, task.created_at}]
    Repo.all(query)
  end

  def get_downloaded_tasks(before_date_time) do
    query =
      from task in ConvertTask,
        where: task.downloads_count > 0 and
               task.last_download_time < ^before_date_time
    Repo.all(query)
  end

  def get_outdated_tasks(before_date_time) do
    query =
      from task in ConvertTask,
        where: task.created_at < ^before_date_time
    Repo.all(query)
  end

  def set_state(task, state) do
    changes = %{
      state: state,
      updated_at: Ecto.DateTime.utc
    }
    changeset = ConvertTask.changeset(task, changes)
    Repo.update(changeset)
  end

  def delete(task) do
    Repo.delete(task)
  end
end
