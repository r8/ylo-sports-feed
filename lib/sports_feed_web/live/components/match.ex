defmodule SportsFeedWeb.Components.Match do
  use SportsFeedWeb, :live_component

  alias SportsFeed.Match

  attr :match, Match

  def render(assigns) do
    ~H"""
    <div class="h-[120px] p-1 border border-zinc-200 rounded-md">
      <div class="h-full p-2 flex flex-col items-center justify-between">
        <h2 class="font-bold text-center">{@match.name}</h2>
        <div class="text-center">{@match.status}</div>
      </div>
    </div>
    """
  end
end
