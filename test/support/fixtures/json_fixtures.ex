defmodule SportsFeed.JsonFixtures do
  @moduledoc """
  Provides fixtures for creating JSON map data in tests.
  """
  @status_values ["active", "paused", "completed"]

  def json_message_fixture(attrs \\ %{}) do
    generated_attrs = %{
      "match_id" => :rand.uniform(200_000),
      "name" => "#{Faker.Team.En.name()} vs #{Faker.Team.En.name()}",
      "status" => Enum.random(@status_values),
      "delay" => :rand.uniform(1000),
      "crash" => Enum.random([false, true])
    }

    Map.merge(generated_attrs, attrs)
  end
end
