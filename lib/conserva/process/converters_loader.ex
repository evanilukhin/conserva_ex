defmodule Conserva.ConvertersLoader do
  require Logger
  
  def get_converters do
    converters_dir = Application.fetch_env!(:conserva, :converters_dir)
    if File.exists?(converters_dir) && File.dir?(converters_dir) do
      for file <- File.ls!(converters_dir),
          path = Path.join(converters_dir, file),
          File.regular?(path) && Path.extname(path) == ".yaml" do
        YamlElixir.read_from_file(path) |> Conserva.Converter.new
      end
    else
      Logger.error("Path #{converters_dir} not exists or not a directory", subsystem: :converters)
      []
    end
  end
end
