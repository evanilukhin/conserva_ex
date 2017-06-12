defmodule Mix.Tasks.Conserva.CleanOutdatedTask do
  use Mix.Task
  import Mix.Ecto

  @shortdoc "Clear outdated files. (Run every 3-10 days)"
  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:timex)
    ensure_repo(Conserva.Repo, [])
    ensure_started(Conserva.Repo, [])
    tasks_store_days =
      System.get_env("tasks_store_days")
      |> String.to_integer
    clean_time =
      Timex.now
      |> Timex.shift(days: -tasks_store_days)
      |> Ecto.DateTime.cast!
    Conserva.ConvertTask.RepoInteraction.get_outdated_tasks(clean_time)
    |> Enum.each(fn(task) -> remove_task(task) end)
  end

  defp remove_task(task) do
    file_storage_path = Application.get_env(:conserva, :file_storage_path)
    if task.source_file do
      Path.join(file_storage_path, task.source_file) |> rm_file
    end
    if task.converted_file do
      Path.join(file_storage_path, task.converted_file) |> rm_file
    end
    Conserva.Repo.delete(task)
  end

  defp rm_file(path) do
    case File.rm(path) do
      :ok ->
        "Succesful deleting file #{path}"
      {:error, :enoent} ->
        "File #{path} unexist"
      {:error, :eacces} ->
        "Missing permission for #{path}"
      _ ->
        "On deleting file #{path} unexpected error occured"
    end |> Mix.shell.info
  end
end
