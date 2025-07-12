defmodule SportsFeed.Matches.MatchServers.RegistryTest do
  use ExUnit.Case, async: false

  alias SportsFeed.Matches.MatchServers

  setup do
    start_supervised!(MatchServers.Registry)
    start_supervised!(SportsFeed.Matches.State)

    :ok
  end

  describe "via_tuple/1" do
    test "returns proper via tuple format" do
      match_id = 456

      result = MatchServers.Registry.via_tuple(match_id)

      assert result == {:via, Registry, {MatchServers.Registry, match_id}}
    end

    test "via_tuple can be used to start a GenServer" do
      match_id = 789
      _via_tuple = MatchServers.Registry.via_tuple(match_id)

      # Start a Server using the via tuple
      {:ok, pid} = MatchServers.Server.start_link(match_id)

      assert Process.alive?(pid)
      assert Registry.lookup(MatchServers.Registry, match_id) == [{pid, nil}]
    end

    test "different match_ids produce different via tuples" do
      match_id1 = 111
      match_id2 = 222

      via_tuple1 = MatchServers.Registry.via_tuple(match_id1)
      via_tuple2 = MatchServers.Registry.via_tuple(match_id2)

      assert via_tuple1 != via_tuple2
      assert {:via, Registry, {MatchServers.Registry, match_id1}} == via_tuple1
      assert {:via, Registry, {MatchServers.Registry, match_id2}} == via_tuple2
    end
  end

  describe "find_server/1" do
    test "returns {:ok, pid} when server is registered" do
      match_id = 333

      {:ok, pid} = MatchServers.Server.start_link(match_id)

      result = MatchServers.Registry.find_server(match_id)

      assert {:ok, ^pid} = result
    end

    test "returns nil when server is not registered" do
      match_id = 999

      result = MatchServers.Registry.find_server(match_id)

      assert result == nil
    end

    test "returns nil after registered server dies" do
      match_id = 444

      {:ok, pid} = MatchServers.Server.start_link(match_id)

      assert {:ok, ^pid} = MatchServers.Registry.find_server(match_id)

      GenServer.stop(pid)

      # Wait for registry cleanup
      Process.sleep(100)
      assert MatchServers.Registry.find_server(match_id) == nil
    end
  end
end
