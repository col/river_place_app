defmodule RiverPlaceApp.Router do
  use RiverPlaceApp.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :secured_api do
    plug :fetch_session
    plug :accepts, ["json"]

    plug Oauth2Server.Secured
  end

  # scope "/api", RiverPlaceApp do
  #   pipe_through :api
  #
  #   scope "/v1", v1, as: :v1 do
  #     post "/login", UserApiController, :login
  #
  #     scope "/auth", auth, as: :auth do
  #       pipe_through :secured_api
  #       post "/get-details", UserApiAuthController, :get_details
  #     end
  #   end
  # end

  scope "/", RiverPlaceApp do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController
  end

  # Other scopes may use custom stacks.
  # scope "/api", RiverPlaceApp do
  #   pipe_through :api
  # end
end
