defmodule Conserva.Factory.ApiKey do
  use ExMachina.Ecto, repo: Conserva.Repo

  def api_key_factory do
    %Conserva.ApiKey{
      uuid: Ecto.UUID.generate(),
      name: sequence("Name"),
      comment: sequence("Comment")
    }
  end

  def convert_task_factory do
    %Conserva.ConvertTask{
      state: "created"
    }
  end
end
