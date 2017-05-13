defmodule Conserva.ConvertTask.Methods do
  def form_converted_file(task) do
    basename = Path.basename(task.source_file, ".#{task.input_extension}")
    "#{basename}.#{task.output_extension}"
  end

  def form_result_filename(task) do
    basename = Path.basename(task.source_filename, ".#{task.input_extension}")
    "#{basename}.#{task.output_extension}"
  end
end
