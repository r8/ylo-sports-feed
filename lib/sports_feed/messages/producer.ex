defmodule SportsFeed.Messages.Producer do
  use GenServer

  require Logger

  alias SportsFeed.Message

  @otp_app :sports_feed

  @retries 3
  @initial_wait 7000
  @wait_before_retry 5000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    # Let's wait for the application to fully start
    Process.send_after(self(), :run, @initial_wait)

    {:ok, %{retries: 0}}
  end

  def handle_info(:run, %{retries: retries} = state) do
    case load_and_cast_messages() do
      :ok ->
        {:noreply, state}

      {:error, reason} when retries < @retries ->
        Logger.error("Failure to load and cast messages: #{inspect(reason)}. Retrying...")

        Process.send_after(self(), :run, @wait_before_retry)
        {:noreply, %{state | retries: retries + 1}}

      {:error, reason} ->
        Logger.critical(
          "Failure to load and cast messages after #{retries} retries: #{inspect(reason)}. Stopping..."
        )

        {:stop, reason, state}
    end
  end

  defp load_and_cast_messages do
    filepath = get_file_path()

    with {:ok, content} <- File.read(filepath),
         {:ok, data} <- Jason.decode(content) do
      Enum.each(data, fn item ->
        cast_message(item)
      end)
    else
      {:error, :enoent} ->
        {:error, "No such file or directory"}
    end
  end

  defp cast_message(item) do
    case Message.from_map(item) do
      {:ok, message} ->
        SportsFeed.Matches.Processor.add_message(message)

      {:error, reason} ->
        Logger.error("Message parsing error: #{reason}. Skipping... #{inspect(item)}",
          reason: reason,
          item: item
        )
    end
  end

  defp get_file_path() do
    filename = Application.get_env(@otp_app, :updates_file_name)
    Application.app_dir(@otp_app, "priv/#{filename}")
  end
end
