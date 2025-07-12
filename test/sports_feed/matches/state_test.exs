defmodule SportsFeed.Matches.StateTest do
  use ExUnit.Case

  alias SportsFeed.Matches.State
  alias SportsFeed.Match

  import SportsFeed.MatchFixtures

  setup do
    # Clear the state for each test
    Agent.update(State, fn _state -> %{} end)
    :ok
  end

  describe "set/2" do
    test "stores a match" do
      match = match_fixture()
      %Match{id: id} = match

      assert :ok = State.set(id, match)
      assert {:ok, ^match} = State.get(id)
    end

    test "overwrites existing match data for same id" do
      id = 200

      match1 = match_fixture(%{id: id, status: "active"})
      match2 = match_fixture(%{id: id, status: "finished"})

      State.set(id, match1)
      State.set(id, match2)

      assert {:ok, ^match2} = State.get(id)
    end

    test "stores multiple matches with different ids" do
      match1 = match_fixture()
      match2 = match_fixture()

      State.set(match1.id, match1)
      State.set(match2.id, match2)

      assert {:ok, ^match1} = State.get(match1.id)
      assert {:ok, ^match2} = State.get(match2.id)
    end
  end

  describe "get/1" do
    test "returns {:ok, match} when match exists" do
      match = match_fixture()
      State.set(match.id, match)

      assert {:ok, ^match} = State.get(match.id)
    end

    test "returns :error when match does not exist" do
      assert :error = State.get(999)
    end
  end

  describe "all/0" do
    test "returns empty list when no matches are stored" do
      assert [] = State.all()
    end

    test "returns single match when one match is stored" do
      match = match_fixture()
      State.set(match.id, match)

      assert [^match] = State.all()
    end

    test "returns all matches when multiple matches are stored" do
      match1 = match_fixture(%{id: 1})
      match2 = match_fixture(%{id: 2})
      match3 = match_fixture(%{id: 3})

      State.set(match1.id, match1)
      State.set(match2.id, match2)
      State.set(match3.id, match3)

      matches = State.all()
      assert length(matches) == 3
      assert match1 in matches
      assert match2 in matches
      assert match3 in matches
    end
  end
end
