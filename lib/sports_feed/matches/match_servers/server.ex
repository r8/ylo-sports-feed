defmodule SportsFeed.Matches.MatchServers.Server do
  use GenServer

  alias SportsFeedWeb.Components.Match
  alias SportsFeed.{Match, Message}
  alias SportsFeed.Matches.State
  alias SportsFeed.Matches.MatchServers.Registry

  def start_link({init_arg, match_id}) do
    GenServer.start_link(__MODULE__, init_arg, name: via_tuple(match_id))
  end

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  def process_message(pid, message) do
    GenServer.cast(pid, {:process_message, message})
  end

  defp via_tuple(match_id) do
    Registry.via_tuple(match_id)
  end

  @impl true
  def handle_cast({:process_message, %Message{} = message}, state) do
    if message.delay > 0 do
      Process.sleep(message.delay)
    end

    match = %Match{
      id: message.match_id,
      name: message.name,
      status: message.status
    }

    State.set(message.match_id, match)

    Phoenix.PubSub.broadcast(
      SportsFeed.PubSub,
      "match_updates",
      {:match_updated, match.id, match}
    )

    {:noreply, state}
  end
end
