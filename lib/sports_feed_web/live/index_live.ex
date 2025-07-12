defmodule SportsFeedWeb.IndexLive do
  use SportsFeedWeb, :live_view

  alias SportsFeed.Matches

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(SportsFeed.PubSub, "match_updates")

    {:ok,
     socket
     |> stream_configure(:matches, dom_id: &"match-#{&1.id}")
     |> stream(:matches, get_initial_matches())}
  end

  @impl true
  def handle_info({:match_updated, _match_id, match}, socket) do
    {:noreply, socket |> stream_insert(:matches, match)}
  end

  defp get_initial_matches() do
    Matches.State.all()
  end
end
