defmodule SportsFeedWeb.IndexLive do
  @moduledoc """
  LiveView for displaying the list of matches.
  Subscribes to match updates and streams the current matches.
  """
  use SportsFeedWeb, :live_view

  alias SportsFeed.Matches

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe to live match updates
    Phoenix.PubSub.subscribe(SportsFeed.PubSub, "match_updates")

    {:ok,
     socket
     # Initialize the socket with the current matches data
     |> stream_configure(:matches, dom_id: &"match-#{&1.id}")
     |> stream(:matches, get_initial_matches())}
  end

  @doc """
  Receives match updates from the PubSub system.
  """
  @impl true
  def handle_info({:match_updated, _match_id, match}, socket) do
    # When a match is updated, insert it into the stream.
    # LiveView will automatically update the UI,
    # replacing the block that has the same DOM id as a new one.
    {:noreply, socket |> stream_insert(:matches, match)}
  end

  # Loads the initial matches from the state agent.
  defp get_initial_matches() do
    Matches.State.all()
  end
end
