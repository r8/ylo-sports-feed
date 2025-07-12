defmodule SportsFeed.Matches.MatchServers.Server do
  use GenServer
  require Logger

  alias SportsFeedWeb.Components.Match
  alias SportsFeed.{Match, Message}
  alias SportsFeed.Matches
  alias SportsFeed.Matches.MatchServers.Registry

  defstruct match_id: nil, queue: nil, processing?: false

  def start_link(match_id) do
    GenServer.start_link(__MODULE__, match_id, name: via_tuple(match_id))
  end

  @impl true
  def init(match_id) do
    state = %__MODULE__{
      match_id: match_id,
      queue: :queue.new(),
      processing?: false
    }

    {:ok, state}
  end

  def add_message(pid, message) do
    GenServer.cast(pid, {:add_message, message})
  end

  defp via_tuple(match_id) do
    Registry.via_tuple(match_id)
  end

  @impl true
  def handle_cast({:add_message, %Message{} = message}, state) do
    updated_queue = :queue.in(message, state.queue)
    updated_state = %{state | queue: updated_queue}

    if !state.processing? do
      {:noreply, schedule_next_message(updated_state)}
    else
      {:noreply, updated_state}
    end
  end

  @impl true
  def handle_info(:process_message, state) do
    case :queue.out(state.queue) do
      {{:value, message}, updated_queue} ->
        try do
          do_process_message(message)
        rescue
          e ->
            Logger.error(Exception.message(e), message: message)
        end

        updated_state = %{state | queue: updated_queue}

        if :queue.is_empty(updated_queue) do
          {:noreply, %{updated_state | processing?: false}}
        else
          {:noreply, schedule_next_message(updated_state)}
        end

      {:empty, _} ->
        %{state | processing?: false}
    end
  end

  defp do_process_message(%Message{} = message) do
    if message.crash do
      raise "Exception for match #{message.match_id}"
    end

    match = %Match{
      id: message.match_id,
      name: message.name,
      status: message.status
    }

    Matches.State.set(message.match_id, match)

    Phoenix.PubSub.broadcast(
      SportsFeed.PubSub,
      "match_updates",
      {:match_updated, match.id, match}
    )

    Logger.info("Message for match #{message.match_id} has been processed", message: message)
  end

  defp schedule_next_message(state) do
    case :queue.out(state.queue) do
      {{:value, message}, _queue} ->
        Process.send_after(self(), :process_message, message.delay)

        %{state | processing?: true}

      {:empty, _} ->
        %{state | processing?: false}
    end
  end
end
