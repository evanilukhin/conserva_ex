defmodule Conserva.ConvertersLoader do
  def get_converters do
    converer_files = File.ls!('converters')
    converters_dir = 'converters'
    for file <- File.ls!(converters_dir),
        path = Path.join(converters_dir, file),
        File.regular?(path) && Path.extname(path) == ".yaml" do
      YamlElixir.read_from_file(path) |> Conserva.Converter.new
    end
  end
end
