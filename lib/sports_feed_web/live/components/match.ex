defmodule SportsFeedWeb.Components.Match do
  @moduledoc """
  Live component for displaying match information.
  """
  use SportsFeedWeb, :live_component

  alias SportsFeed.Match

  attr :id, :string
  attr :match, Match

  def render(assigns) do
    ~H"""
    <div id={@id} class="h-[120px] p-1 border border-zinc-200 rounded-md" style={"order:#{@match.id};"}>
      <div class={[
        "h-full p-2 pt-1 flex flex-col justify-between",
        @match.status == "active" && "bg-green-100",
        @match.status == "paused" && "bg-red-100"
      ]}>
        <div>
          <div class="w-full text-right text-[8px] text-zinc-500 pb-1">{@match.id}</div>
          <h2 class="font-bold text-center">{@match.name}</h2>
        </div>
        <div class="text-center">{@match.status}</div>
      </div>
    </div>
    """
  end
end
