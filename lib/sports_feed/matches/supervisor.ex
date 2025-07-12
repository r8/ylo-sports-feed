defmodule SportsFeed.Matches.Supervisor do
  use Supervisor
  alias SportsFeed.Matches.State

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      State
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
