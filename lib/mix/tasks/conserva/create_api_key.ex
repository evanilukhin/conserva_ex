defmodule Mix.Tasks.Conserva.CreateApiKey do
  use Mix.Task
  import Mix.Ecto

  @shortdoc "create api_key"
  def run(args) do
    ensure_repo(Conserva.Repo, [])
    ensure_started(Conserva.Repo, [])
    api_key_options = api_key_params(args)
    case Conserva.ApiKey.RepoInteraction.create(api_key_options) do
      {:ok, api_key} ->
        Mix.shell.info(api_key.uuid)
      {:error, _unsaved_key} ->
        Mix.shell.info("key was not created")
    end
  end

  defp api_key_params(raw_args) do
    {parsed_options, _, _} =
      OptionParser.parse(raw_args,
                         strict: [name: :string, comment: :string],
                         aliases: [n: :name, c: :comment])
    parsed_options

  end
end
