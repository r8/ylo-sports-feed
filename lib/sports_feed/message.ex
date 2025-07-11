defmodule SportsFeed.Message do
  defstruct match_id: nil, name: "", status: nil, delay: 0, crash: false

  def new(%{match_id: match_id, delay: delay, status: status, name: name, crash: crash}) do
    %__MODULE__{
      match_id: match_id,
      name: name,
      status: status,
      delay: delay,
      crash: crash
    }
  end
end
