defmodule Conserva.ConvertTask.Methods do
  def form_converted_file(task) do
    basename = Path.rootname(task.source_file)
    "#{basename}.#{task.output_extension}"
  end

  def form_result_filename(task) do
    basename = Path.rootname(task.source_filename)
    "#{basename}.#{task.output_extension}"
  end
end
