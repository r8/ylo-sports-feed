defmodule SportsFeed.MessageFixtures do
  @moduledoc """
  Provides fixtures for creating message data in tests.
  """
  @status_values ["active", "paused", "completed"]

  def message_fixture(attrs \\ %{}) do
    generated_attrs = %{
      match_id: :rand.uniform(200_000),
      name: "#{Faker.Team.En.name()} vs #{Faker.Team.En.name()}",
      status: Enum.random(@status_values),
      delay: :rand.uniform(1000),
      crash: Enum.random([false, true])
    }

    %SportsFeed.Message{}
    |> struct!(Enum.into(attrs, generated_attrs))
  end
end
