defmodule SportsFeed.Matches.State do
  @moduledoc """
  Agent for storing match data
  """
  use Agent

  alias SportsFeed.Match

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Sets the match data for a given match id.
  """
  def set(match_id, %Match{} = match) when is_number(match_id) do
    Agent.update(__MODULE__, fn state -> Map.put(state, match_id, match) end)
  end

  @doc """
  Gets the match data for a given match id.
  Returns `{:ok, match}` if found, or `:error` if not found.
  """
  def get(match_id) do
    Agent.get(__MODULE__, fn state -> Map.fetch(state, match_id) end)
  end

  @doc """
  Returns a list of all matches stored in the agent.
  """
  def all() do
    Agent.get(__MODULE__, fn state ->
      state |> Map.values()
    end)
  end
end
