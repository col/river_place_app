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

  pipeline :api do
    plug Plug.Parsers,
      parsers: [AlexaVerifier.JSONParser],
      pass: ["*/*"],
      json_decoder: Poison

    plug AlexaVerifier.Plug
  end

  pipeline :secured_api do
    plug :fetch_session
    plug :accepts, ["json"]

    plug Oauth2Server.Secured
  end

  scope "/api", RiverPlaceApp.Api, as: :api do
    pipe_through :api

    post "/command", AlexaController, :handle_request
    get "/mock_command", AlexaController, :mock_request
  end

  scope "/", RiverPlaceApp do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/privacy", PageController, :privacy
    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/oauth/authorize", AuthorizeController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", RiverPlaceApp do
  #   pipe_through :api
  # end
end
