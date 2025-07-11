defmodule SportsFeedWeb.IndexLive do
  use SportsFeedWeb, :live_view

  alias SportsFeed.Message

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream_configure(:matches, dom_id: &"match-#{&1.match_id}")
     |> stream(:matches, get_messages())}
  end

  defp get_messages() do
    [
      %Message{
        match_id: 1,
        name: "First match",
        status: "active",
        delay: 100,
        crash: false
      },
      %Message{
        match_id: 2,
        name: "Second match",
        status: "paused",
        delay: 100,
        crash: false
      },
      %Message{
        match_id: 3,
        name: "Third match",
        status: "active",
        delay: 100,
        crash: false
      },
      %Message{
        match_id: 1,
        name: "First match",
        status: "paused",
        delay: 100,
        crash: false
      },
      %Message{
        match_id: 2,
        name: "Second match",
        status: "active",
        delay: 100,
        crash: false
      }
    ]
  end
end
