defmodule Conserva.TaskDistributor do
  def add_to_queue(task) do
    converter = GenServer.call(ConvertersInfoServer, {:get_converter_for_task, task})
    if converter do
      GenServer.cast(converter.name, {:add_task, task})
    end
  end
end