defmodule Conserva.TaskDistributor do
  require Logger
  def add_to_queue(task) do
    converter = GenServer.call(ConvertersInfoServer, {:get_converter_for_task, task})
    if converter do
      GenServer.cast(converter.name, {:add_task, task})
      Logger.info("Task #{task.id} added into  converter #{converter.name}", subsystem: :converters)
    else
      Logger.warn("For task: #{task.id} converter was not find", subsystem: :converters)
    end
  end
end
