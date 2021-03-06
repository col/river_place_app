defmodule RiverPlaceApp.Router do
  use RiverPlaceApp.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug RiverPlaceApp.Auth, repo: RiverPlaceApp.Repo
  end

  pipeline :alexa do
    plug Plug.Parsers,
      parsers: [AlexaVerifier.JSONParser],
      pass: ["*/*"],
      json_decoder: Poison

    plug AlexaVerifier.Plug
  end

  pipeline :api do
    plug Plug.Parsers,
      parsers: [:json],
      pass: ["*/*"],
      json_decoder: Poison

    plug :accepts, ["html", "json"]
  end

  pipeline :secured_api do
    plug :fetch_session
    plug :accepts, ["json"]

    plug Oauth2Server.Secured
  end

  scope "/api", RiverPlaceApp.Api, as: :api do
    pipe_through :alexa

    post "/command", AlexaController, :handle_request
    get "/mock_command", AlexaController, :mock_request
  end

  scope "/messenger", RiverPlaceApp, as: :messenger do
    pipe_through :api

    get "/webhook", MessengerController, :validate
    post "/webhook", MessengerController, :webhook
  end

  scope "/api.ai", RiverPlaceApp, as: :api_ai do
    pipe_through :api

    post "/webhook", ApiAiController, :webhook
  end

  scope "/", RiverPlaceApp do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/privacy", PageController, :privacy
    get "/terms", PageController, :terms
    get "/contact", PageController, :contact
    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/oauth/authorize", AuthorizeController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", RiverPlaceApp do
  #   pipe_through :api
  # end
end
