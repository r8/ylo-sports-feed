defmodule SportsFeed.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SportsFeedWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:sports_feed, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SportsFeed.PubSub},
      # Start message producer
      SportsFeed.Producers.MessageProducer,
      # Start Matches Supervisor
      SportsFeed.Matches.Supervisor,
      # Start to serve requests, typically the last entry
      SportsFeedWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SportsFeed.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SportsFeedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
