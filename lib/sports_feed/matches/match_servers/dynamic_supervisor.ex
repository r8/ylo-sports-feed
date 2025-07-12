defmodule SportsFeed.Matches.MatchServers.DynamicSupervisor do
  use DynamicSupervisor

  alias SportsFeed.Matches.MatchServers.Server

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(match_id) do
    DynamicSupervisor.start_child(__MODULE__, {Server, match_id})
  end
end
