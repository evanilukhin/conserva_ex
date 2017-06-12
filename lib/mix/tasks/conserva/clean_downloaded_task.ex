defmodule Mix.Tasks.Conserva.CleanDownloadedTask do
  use Mix.Task
  import Mix.Ecto

  @shortdoc "Clear downloaded files. (Run every 1-10 minutes)"
  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:timex)
    ensure_repo(Conserva.Repo, [])
    ensure_started(Conserva.Repo, [])
    downloaded_tasks_store_time_in_seconds =
      System.get_env("downloaded_tasks_store_time_in_seconds")
      |> String.to_integer
    clean_time =
      Timex.now
      |> Timex.shift(seconds: -downloaded_tasks_store_time_in_seconds)
      |> Ecto.DateTime.cast!
    Conserva.ConvertTask.RepoInteraction.get_downloaded_tasks(clean_time)
    |> Enum.each(fn(task) -> remove_task(task) end)
  end

  defp remove_task(task) do
    file_storage_path = Application.get_env(:conserva, :file_storage_path)
    Path.join(file_storage_path, task.source_file) |> rm_file
    Path.join(file_storage_path, task.converted_file) |> rm_file
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
