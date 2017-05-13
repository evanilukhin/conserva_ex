defmodule Conserva.TaskProcessor do
  def convert(task, converter) do
    build_parameters(task, converter)
    |> substitute_params
    |> launch
    |> commit_result
  end

  defp build_parameters(task, converter) do
    file_storage_path = Application.get_env(:conserva, :file_storage_path)
    relative_result_path = Conserva.ConvertTask.Methods.form_converted_file(task)
    full_result_path = Path.join(file_storage_path, relative_result_path)
    substituting_array = [
      {"{:output_dir}", file_storage_path},
      {"{:full_source_path}", Path.join(file_storage_path, task.source_file)},
      {"{:full_result_path}", full_result_path},
      {"{:input_extension}", task.input_extension},
      {"{:output_extension}", task.output_extension}
    ]
    %{substituting_array: substituting_array,
      relative_result_path: relative_result_path,
      full_result_path: full_result_path,
      task: task,
      raw_launch_string: converter.launch_string}
  end

  defp substitute_params(params) do
    launch_string =
      Enum.reduce(params.substituting_array,
                  params.raw_launch_string,
                  fn({from, to}, acc) -> String.replace(acc, from, to) end)
    Map.put(params, :launch_string, launch_string)
  end

  defp launch(params) do
    result_string = :os.cmd(String.to_charlist(params.launch_string))
    if File.exists? params.full_result_path do
      result_file_sha256 =
        File.stream!(params.full_result_path, [], 2048)
        |> Enum.reduce(:crypto.hash_init(:sha256),fn(line, acc) -> :crypto.hash_update(acc,line) end )
        |> :crypto.hash_final
        |> Base.encode16
      {:ok, Map.put(params, :result_file_sha256, result_file_sha256)}
    else
      {:error, Map.put(params, :error_output, result_string)}
    end
  end

  defp commit_result(result) do
    case result do
      {:ok, params} ->
        succeed_convert_commit(params)
      {:error, params} ->
        failed_convert_commit(params)
    end
  end

  defp succeed_convert_commit(params) do
    changes = %{
      result_filename: Conserva.ConvertTask.Methods.form_result_filename(params.task),
      converted_file: params.relative_result_path,
      state: "finished",
      result_file_sha256: params.result_file_sha256,
      updated_at: Ecto.DateTime.utc,
      finished_at: Ecto.DateTime.utc
    }
    changeset = Conserva.ConvertTask.changeset(params.task, changes)
    if changeset.valid? do
      Conserva.Repo.update(changeset)
    else
      File.rm(params.full_result_path)
      {:error, changeset.errors}
    end
  end

  defp failed_convert_commit(params) do
    changes = %{
      state: "error",
      updated_at: Ecto.DateTime.utc,
      errors: params.error_output
    }
    changeset = Conserva.ConvertTask.changeset(params.task, changes)
    if changeset.valid? do
      Conserva.Repo.update(changeset)
    else
      {:error, changeset.errors}
    end
  end
end
