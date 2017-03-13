defmodule Conserva.TaskProcessor.Supervisor do
  use Supervisor

  def start_link(options) do
    Supervisor.start_link(__MODULE__,[], options)
  end

  def init(options) do
    children = [
      supervisor(Conserva.TaskProcessor.ImageMagic.Supervisor, [[count_workers: 3], [name: Conserva.TaskProcessor.ImageMagic.Supervisor]]),
      supervisor(Conserva.TaskProcessor.LibreOffice.Supervisor, [[count_workers: 4], [name: Conserva.TaskProcessor.LibreOffice.Supervisor]]),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
