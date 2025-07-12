# Stop GenServer processes that will be started by the tests
Supervisor.terminate_child(SportsFeed.Supervisor, SportsFeed.Messages.Producer)
Supervisor.terminate_child(SportsFeed.Supervisor, SportsFeed.Matches.Supervisor)

ExUnit.start()
Faker.start()
