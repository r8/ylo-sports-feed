defmodule SportsFeedWeb.IndexLive do
  use SportsFeedWeb, :live_view

  alias SportsFeed.Match

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:matches, get_matches())}
  end

  defp get_matches() do
    [
      %Match{
        id: 1,
        name: "First match",
        status: "active"
      },
      %Match{
        id: 2,
        name: "Second match",
        status: "paused"
      },
      %Match{
        id: 3,
        name: "Third match",
        status: "active"
      },
      %Match{
        id: 1,
        name: "First match",
        status: "paused"
      },
      %Match{
        id: 2,
        name: "Second match",
        status: "active"
      }
    ]
  end
end
