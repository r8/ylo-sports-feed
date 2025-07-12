defmodule SportsFeed.Matches.Processor do
  alias SportsFeed.Message
  alias SportsFeed.Matches.MatchServers

  def add_message(%Message{match_id: match_id} = message) do
    case find_or_start_match_server(match_id) do
      {:ok, pid} ->
        MatchServers.Server.add_message(pid, message)
        :ok

      _ ->
        {:error, "Cannot find or start MatchServer"}
    end
  end

  defp find_or_start_match_server(match_id) do
    case MatchServers.Registry.find_server(match_id) do
      {:ok, pid} -> {:ok, pid}
      _ -> MatchServers.DynamicSupervisor.start_child(match_id)
    end
  end
end
