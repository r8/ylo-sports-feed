defmodule SportsFeed.Matches.Supervisor do
  use Supervisor

  alias SportsFeed.Matches
  alias SportsFeed.Matches.MatchServers

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      Matches.State,
      MatchServers.Registry,
      MatchServers.DynamicSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
