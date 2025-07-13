defmodule SportsFeed.Matches.MatchServers.ServerTest do
  use ExUnit.Case, async: true

  alias SportsFeed.Match
  alias SportsFeed.Matches.MatchServers.{Registry, Server}
  alias SportsFeed.Matches.State

  import SportsFeed.MessageFixtures

  setup do
    start_supervised!(Registry)
    start_supervised!(State)

    # Create a unique match_id for each test
    match_id = System.unique_integer([:positive])
    {:ok, pid} = Server.start_link(match_id)

    {:ok, pid: pid, match_id: match_id}
  end

  describe "initialization" do
    test "starts with empty queue", %{pid: pid, match_id: match_id} do
      state = Server.get_state(pid)

      assert state.match_id == match_id
      assert :queue.is_empty(state.queue)
      refute state.processing?
    end
  end

  describe "add_message/2" do
    test "adds message to queue and starts processing", %{pid: pid, match_id: match_id} do
      message =
        message_fixture(%{
          match_id: match_id,
          delay: 20
        })

      Server.add_message(pid, message)

      # Wait for the cast to be processed
      Process.sleep(10)

      state = Server.get_state(pid)
      assert state.processing?
      assert :queue.len(state.queue) == 1
    end

    test "queues multiple messages", %{pid: pid, match_id: match_id} do
      message1 =
        message_fixture(%{
          match_id: match_id,
          delay: 50
        })

      message2 =
        message_fixture(%{
          match_id: match_id,
          delay: 10
        })

      Server.add_message(pid, message1)
      Server.add_message(pid, message2)

      # Wait for the cast to be processed
      Process.sleep(10)

      state = Server.get_state(pid)
      assert state.processing?
      assert :queue.len(state.queue) == 2
    end
  end

  describe "message processing" do
    test "processes message and updates state", %{pid: pid, match_id: match_id} do
      message =
        message_fixture(%{
          match_id: match_id,
          delay: 10,
          crash: false
        })

      Server.add_message(pid, message)

      # Wait for message to be processed
      Process.sleep(20)

      # Check that the match was updated in the State Agent
      {:ok, match} = State.get(match_id)
      assert match.id == match_id
      assert match.name == message.name
      assert match.status == message.status

      # Assert that the queue is empty after processing
      state = Server.get_state(pid)
      assert :queue.is_empty(state.queue)
      refute state.processing?
    end

    test "processes multiple messages in order", %{pid: pid, match_id: match_id} do
      message1 =
        message_fixture(%{
          match_id: match_id,
          delay: 10,
          crash: false
        })

      message2 =
        message_fixture(%{
          match_id: match_id,
          delay: 10,
          crash: false
        })

      Server.add_message(pid, message1)
      Server.add_message(pid, message2)

      # Wait for both messages to be processed
      Process.sleep(30)

      # The last message should be the one in state
      {:ok, match} = State.get(match_id)
      assert match.name == message2.name
      assert match.status == message2.status

      # Queue should be empty after processing
      state = Server.get_state(pid)
      assert :queue.is_empty(state.queue)
      refute state.processing?
    end

    test "continues processing after exception", %{pid: pid, match_id: match_id} do
      crash_message =
        message_fixture(%{
          match_id: match_id,
          delay: 10,
          crash: true
        })

      normal_message =
        message_fixture(%{
          match_id: match_id,
          delay: 10,
          crash: false
        })

      Server.add_message(pid, crash_message)
      Server.add_message(pid, normal_message)

      # Wait for both messages to be processed
      Process.sleep(30)

      # The normal message should have been processed
      {:ok, match} = State.get(match_id)
      assert match.name == normal_message.name
      assert match.status == normal_message.status
    end
  end

  describe "PubSub integration" do
    test "broadcasts match updates", %{pid: pid, match_id: match_id} do
      # Subscribe to match updates
      Phoenix.PubSub.subscribe(SportsFeed.PubSub, "match_updates")

      message =
        message_fixture(%{
          match_id: match_id,
          delay: 10,
          crash: false
        })

      Server.add_message(pid, message)

      assert_receive {:match_updated, ^match_id, %Match{name: name, status: status}}, 50
      assert name == message.name
      assert status == message.status
    end
  end
end
