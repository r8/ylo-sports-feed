defmodule SportsFeed.Matches.MatchServers.Registry do
  def start_link() do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def via_tuple(match_id) do
    {:via, Registry, {__MODULE__, match_id}}
  end

  def find_server(match_id) do
    case Registry.lookup(__MODULE__, match_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> nil
    end
  end

  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end
