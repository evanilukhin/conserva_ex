defmodule Conserva.ConvertersServer do
  use GenServer

  def start_link(opts \\ []) do
    converters = Conserva.ConvertersLoader.get_converters
    GenServer.start_link(__MODULE__, converters, opts)
  end

  def handle_call(:get_converters, _from, converters) do
    {:reply, converters, converters}
  end

  def handle_call({:get_converter_for_task, task}, _from, converters) do
    converter =
      Enum.find(converters, fn(converter) ->
        Enum.member?(converter_combinations(converter), [task.input_extension, task.output_extension])
      end)
    {:reply, converter, converters}
  end

  def handle_call(:get_convert_combinations, _from, converters) do
    convert_combiantions =
      Enum.reduce(converters, [], fn(x, acc) -> acc ++ converter_combinations(x) end)
    {:reply, convert_combiantions, converters}
  end

  def handle_cast(:reload_converters, _converters) do
    reloaded_converters = Conserva.ConvertersLoader.get_converters
    {:noreply, reloaded_converters}
  end

  defp converter_combinations(converter) do
    for i <- converter.from_ext, j <- converter.to_ext, do: [i, j]
  end
end
