defmodule Conserva.Plug.NewTaskFetcher do
  import Plug.Conn
  require IEx

  def init(options), do: options

  def call(%Plug.Conn{request_path: path, method: method} = conn, opts) do
    if Enum.join([String.downcase(method), path], " ") in opts[:paths] do
      conn = assign_fetched_data(conn)
    end
    conn
  end

  def assign_fetched_data(conn) do
    input_extension = conn.params["input_extension"]
    output_extension = conn.params["output_extension"]
    input_file = conn.params["file"]

    file_name = "#{Integer.to_string(:os.system_time())}_#{input_file.filename}"
    file_storage_path = Application.fetch_env!(:conserva, :file_storage_path)

    unless File.exists? (file_storage_path) do
      File.mkdir file_storage_path
    end

    potential_file_path = "#{file_storage_path}/#{file_name}"

    File.stream!(input_file.path, [], 2048)
      |> Stream.into(File.stream!(potential_file_path))
      |> Stream.run

    input_file_sha256 =
      File.stream!(input_file.path, [], 2048)
        |> Enum.reduce(:crypto.hash_init(:sha256),fn(line, acc) -> :crypto.hash_update(acc,line) end )
        |> :crypto.hash_final
        |> Base.encode16

    convert_task = %Conserva.ConvertTask{source_filename: input_file.filename,
                                         source_file: file_name,
                                         input_extension: input_extension,
                                         output_extension: output_extension,
                                         source_file_sha256: input_file_sha256,
                                         api_key_id: conn.assigns[:api_key_id]}
    assign(conn, :changeset, convert_task) |> assign(:potential_file_path, potential_file_path)
  end
end
