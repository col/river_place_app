defmodule RiverPlaceApp do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(RiverPlaceApp.Endpoint, []),
      # Start the Ecto repository
      supervisor(RiverPlaceApp.Repo, []),
      supervisor(Oauth2Server.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(RiverPlaceApp.Worker, [arg1, arg2, arg3]),
      worker(RiverPlaceSkill, [[app_id: Application.get_env(:river_place_app, :app_id)]]),
      worker(AlexaVerifier.CertCache, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RiverPlaceApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RiverPlaceApp.Endpoint.config_change(changed, removed)
    :ok
  end
end
