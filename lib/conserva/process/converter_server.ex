defmodule Conserva.ConverterServer do
  require Logger

  use GenServer
  alias Conserva.{ConvertTask, TaskProcessor}

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    task_queue = initialize_task_queue(state.converter)
    new_state =
      Map.merge(state, %{task_queue: task_queue, active_processors_count: 0})
      |> start_processes()
    Logger.info("Started GenServer for converter: #{state.converter.name}", subsystem: :converters)   
    {:ok, new_state}
  end

  def handle_cast({:add_task, task}, state) do
    new_state =
      Map.put(state, :task_queue, :queue.in(task, state.task_queue))
      |> start_processes()
    {:noreply, new_state}
  end

  def handle_cast(:free_worker, state) do
    new_state =
      if :queue.len(state.task_queue) > 0 do
        {{:value, task}, new_queue} = :queue.out(state.task_queue)
        launch_process(task, state[:converter])
        Map.put(state, :task_queue, new_queue)
      else
        active_workers = state.active_processors_count
        new_count_workers =
          if active_workers > 0, do: active_workers - 1, else: active_workers
        Map.put(state, :active_processors_count, new_count_workers)
      end
    {:noreply, new_state}
  end

  defp initialize_task_queue(converter) do
    ConvertTask.RepoInteraction.get_unconverted_tasks_for_converter(converter)
    |> Enum.reduce(:queue.new(), fn(task, queue) -> :queue.in(task, queue) end)
  end

  defp launch_process(task, converter) do
    ConvertTask.RepoInteraction.set_state(task, "process")
    spawn(fn -> TaskProcessor.convert(task, converter) end)
  end

  defp start_processes(state) do
    if state.active_processors_count < state.converter.max_workers_count &&
      :queue.len(state.task_queue) > 0 do
      new_active_workers = state.active_processors_count + 1
      {{:value, converting_task}, new_queue} = :queue.out(state.task_queue)
      launch_process(converting_task, state.converter)
      new_state =
        Map.merge(state, %{task_queue: new_queue, active_processors_count: new_active_workers})
      start_processes(new_state)
    else
      state
    end
  end
end
