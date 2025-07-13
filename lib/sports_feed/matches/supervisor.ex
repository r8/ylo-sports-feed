defmodule SportsFeed.Matches.Supervisor do
  @moduledoc """
  Supervisor for managing the matches subsystem.
  """

  use Supervisor

  alias SportsFeed.Matches
  alias SportsFeed.Matches.MatchServers

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      # Start the State Agent that holds the latest match states
      Matches.State,
      # Start the Registry for match servers
      MatchServers.Registry,
      # Start the DynamicSupervisor for match servers
      MatchServers.DynamicSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
