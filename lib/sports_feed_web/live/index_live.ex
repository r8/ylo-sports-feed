defmodule SportsFeedWeb.IndexLive do
  use SportsFeedWeb, :live_view

  alias SportsFeed.Matches

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:matches, get_initial_matches())}
  end

  defp get_initial_matches() do
    Matches.State.all()
  end
end
