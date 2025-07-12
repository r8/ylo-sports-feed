defmodule SportsFeed.Message do
  defstruct match_id: nil, name: "", status: nil, delay: 0, crash: false

  def from_map(%{
        "match_id" => match_id,
        "name" => name,
        "status" => status,
        "delay" => delay,
        "crash" => crash
      }) do
    {:ok,
     %__MODULE__{
       match_id: match_id,
       name: name,
       status: status,
       delay: delay,
       crash: crash
     }}
  end

  def from_map(_), do: {:error, "Invalid message data"}
end
