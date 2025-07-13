defmodule SportsFeed.MatchFixtures do
  @moduledoc """
  Provides fixtures for creating match data in tests.
  """
  @status_values ["active", "paused", "completed"]

  def match_fixture(attrs \\ %{}) do
    generated_attrs = %{
      id: System.unique_integer([:positive]),
      name: "#{Faker.Team.En.name()} vs #{Faker.Team.En.name()}",
      status: Enum.random(@status_values)
    }

    %SportsFeed.Match{}
    |> struct!(Enum.into(attrs, generated_attrs))
  end
end
