defmodule SportsFeed.Matches.MatchServers.Server do
  @moduledoc """
  A GenServer that processes messages for a specific match.

  Uses Erlang's `:queue` to manage incoming messages
  and processes them in the order they are received.
  """
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

  @doc """
  Adds a message to the match server's queue for processing.
  """
  def add_message(pid, message) do
    GenServer.cast(pid, {:add_message, message})
  end

  @doc """
  Gets the current state of the server
  """
  def get_state(pid) do
    GenServer.call(pid, :state)
  end

  defp via_tuple(match_id) do
    Registry.via_tuple(match_id)
  end

  # Server Callbacks

  # Retrieves the current state of the server.
  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  # Adds message to the queue and schedules processing.
  @impl true
  def handle_cast({:add_message, %Message{} = message}, state) do
    updated_queue = :queue.in(message, state.queue)
    updated_state = %{state | queue: updated_queue}

    if state.processing? do
      {:noreply, updated_state}
    else
      # If not currently processing, schedule the next message
      {:noreply, schedule_next_message(updated_state)}
    end
  end

  # Retrieves and processes the next message in the queue.
  @impl true
  def handle_info(:process_message, state) do
    case :queue.out(state.queue) do
      {{:value, message}, updated_queue} ->
        try do
          do_process_message(message)
        rescue
          e ->
            Logger.error(Exception.message(e))
        end

        updated_state = %{state | queue: updated_queue}

        if :queue.is_empty(updated_queue) do
          {:noreply, %{updated_state | processing?: false}}
        else
          {:noreply, schedule_next_message(updated_state)}
        end

      {:empty, _} ->
        {:noreply, %{state | processing?: false}}
    end
  end

  # Schedules the next message to be processed after its delay.
  defp schedule_next_message(state) do
    case :queue.out(state.queue) do
      {{:value, message}, _queue} ->
        Process.send_after(self(), :process_message, message.delay)

        %{state | processing?: true}

      {:empty, _} ->
        %{state | processing?: false}
    end
  end

  # Processes the message, updates the match state and notifies the UI.
  defp do_process_message(%Message{} = message) do
    if message.crash do
      raise "Exception for match #{message.match_id}"
    end

    match = %Match{
      id: message.match_id,
      name: message.name,
      status: message.status
    }

    # Update the match state in the Matches.State agent
    Matches.State.set(message.match_id, match)

    # Broadcast the updated match to the PubSub system to notify the UI
    Phoenix.PubSub.broadcast(
      SportsFeed.PubSub,
      "match_updates",
      {:match_updated, match.id, match}
    )

    Logger.info("Message for match #{message.match_id} has been processed")
  end
end
