defmodule SportsFeed.Messages.ProducerTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog
  import SportsFeed.JsonFixtures

  alias SportsFeed.Messages.Producer
  alias SportsFeed.Matches

  setup do
    start_supervised!(Matches.Supervisor)

    test_file_path = "test/fixtures/test_messages.json"
    Application.put_env(:sports_feed, :updates_file_path, test_file_path)

    on_exit(fn ->
      Application.delete_env(:sports_feed, :updates_file_path)
      File.rm(Application.app_dir(:sports_feed, test_file_path))
    end)

    {:ok, test_file_path: test_file_path}
  end

  describe "handle_info/2 with :run message" do
    setup %{test_file_path: test_file_path} do
      create_test_file(test_file_path, [
        json_message_fixture()
      ])

      {:ok, pid} = GenServer.start_link(Producer, nil)
      {:ok, producer_pid: pid}
    end

    test "successfully processes messages", %{producer_pid: _pid} do
      state = %{retries: 0}

      assert {:noreply, ^state} = Producer.handle_info(:run, state)
    end

    test "increments retries on error and schedules retry", %{test_file_path: test_file_path} do
      File.rm!(Application.app_dir(:sports_feed, test_file_path))

      state = %{retries: 0}

      assert capture_log(fn ->
        assert {:noreply, %{retries: 1}} = Producer.handle_info(:run, state)
      end) =~ "Failure to load and cast messages"

      assert_receive :run, 6000
    end

    test "stops after max retries", %{test_file_path: test_file_path} do
      File.rm!(Application.app_dir(:sports_feed, test_file_path))

      state = %{retries: 3}

      assert capture_log(fn ->
        assert {:stop, _reason, ^state} = Producer.handle_info(:run, state)
      end) =~ "Failure to load and cast messages after 3 retries"
    end
  end

  describe "load_and_cast_messages/0" do
    test "processes valid JSON messages", %{test_file_path: test_file_path} do
      messages = [
        json_message_fixture(),
        json_message_fixture()
      ]

      create_test_file(test_file_path, messages)

      {:ok, pid} = GenServer.start_link(Producer, nil)
      state = %{retries: 0}

      assert {:noreply, ^state} = Producer.handle_info(:run, state)

      GenServer.stop(pid)
    end

    test "handles invalid JSON gracefully", %{test_file_path: test_file_path} do
      File.write!(Application.app_dir(:sports_feed, test_file_path), "invalid json")

      {:ok, pid} = GenServer.start_link(Producer, nil)
      state = %{retries: 0}

      assert {:noreply, %{retries: 1}} = Producer.handle_info(:run, state)

      GenServer.stop(pid)
    end

    test "handles missing file gracefully", %{test_file_path: test_file_path} do
      File.rm(Application.app_dir(:sports_feed, test_file_path))

      {:ok, pid} = GenServer.start_link(Producer, nil)
      state = %{retries: 0}

      assert capture_log(fn ->
        assert {:noreply, %{retries: 1}} = Producer.handle_info(:run, state)
      end) =~ "Failure to load and cast messages"

      GenServer.stop(pid)
    end

    test "skips messages with invalid format", %{test_file_path: test_file_path} do
      messages = [
        json_message_fixture(),
        %{
          "invalid" => "message format"
        }
      ]

      create_test_file(test_file_path, messages)

      {:ok, pid} = GenServer.start_link(Producer, nil)
      state = %{retries: 0}

      assert capture_log(fn ->
        assert {:noreply, ^state} = Producer.handle_info(:run, state)
      end) =~ "Message parsing error"

      GenServer.stop(pid)
    end
  end

  defp create_test_file(relative_path, messages) do
    full_path = Application.app_dir(:sports_feed, relative_path)
    
    full_path
    |> Path.dirname()
    |> File.mkdir_p!()

    json_content = Jason.encode!(messages)
    File.write!(full_path, json_content)
  end
end
