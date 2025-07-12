defmodule SportsFeed.MatchFixtures do
  @status_values ["active", "paused", "completed"]

  def match_fixture(attrs \\ %{}) do
    generated_attrs = %{
      id: :rand.uniform(200_000),
      name: "#{Faker.Team.En.name()} vs #{Faker.Team.En.name()}",
      status: Enum.random(@status_values)
    }

    %SportsFeed.Match{}
    |> struct!(Enum.into(attrs, generated_attrs))
  end
end
