defmodule SportsFeed.Matches.MatchServers.DynamicSupervisorTest do
  use ExUnit.Case, async: false

  alias SportsFeed.Matches.MatchServers

  setup do
    start_supervised!(MatchServers.Registry)
    start_supervised!(MatchServers.DynamicSupervisor)

    :ok
  end

  describe "start_child/1" do
    test "starts a match server for given match_id" do
      match_id = 123

      {:ok, pid} = MatchServers.DynamicSupervisor.start_child(match_id)

      assert Process.alive?(pid)
      assert {:ok, ^pid} = MatchServers.Registry.find_server(match_id)
    end

    test "returns error when trying to start duplicate match server" do
      match_id = 456

      {:ok, _pid} = MatchServers.DynamicSupervisor.start_child(match_id)

      assert {:error, {:already_started, _pid}} =
               MatchServers.DynamicSupervisor.start_child(match_id)
    end

    test "can start multiple servers with different match_ids" do
      match_id_1 = 111
      match_id_2 = 222

      {:ok, pid1} = MatchServers.DynamicSupervisor.start_child(match_id_1)
      {:ok, pid2} = MatchServers.DynamicSupervisor.start_child(match_id_2)

      assert Process.alive?(pid1)
      assert Process.alive?(pid2)
      assert pid1 != pid2
      assert {:ok, ^pid1} = MatchServers.Registry.find_server(match_id_1)
      assert {:ok, ^pid2} = MatchServers.Registry.find_server(match_id_2)
    end

    test "tracks started children" do
      match_id = 789

      children_before = DynamicSupervisor.which_children(MatchServers.DynamicSupervisor)
      assert length(children_before) == 0

      {:ok, _pid} = MatchServers.DynamicSupervisor.start_child(match_id)

      children_after = DynamicSupervisor.which_children(MatchServers.DynamicSupervisor)
      assert length(children_after) == 1
    end

    test "restarts child server when it crashes (DynamicSupervisor behavior)" do
      match_id = 999

      {:ok, original_pid} = MatchServers.DynamicSupervisor.start_child(match_id)

      assert Process.alive?(original_pid)
      assert {:ok, ^original_pid} = MatchServers.Registry.find_server(match_id)

      # Kill the child process
      Process.exit(original_pid, :kill)
      refute Process.alive?(original_pid)

      # Wait for supervisor to restart the process
      Process.sleep(100)

      assert {:ok, new_pid} = MatchServers.Registry.find_server(match_id)
      assert Process.alive?(new_pid)
      assert new_pid != original_pid

      # Should not be able to start another server with the same match_id
      assert {:error, {:already_started, ^new_pid}} =
               MatchServers.DynamicSupervisor.start_child(match_id)
    end
  end
end
