defmodule SportsFeed.Matches.State do
  use Agent

  alias SportsFeed.Match

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def set(match_id, %Match{} = match) when is_number(match_id) do
    Agent.update(__MODULE__, fn state -> Map.put(state, match_id, match) end)
  end

  def get(match_id) do
    Agent.get(__MODULE__, fn state -> Map.fetch(state, match_id) end)
  end

  def all() do
    Agent.get(__MODULE__, fn state ->
      state |> Map.values()
    end)
  end
end
