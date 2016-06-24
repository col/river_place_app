defmodule RiverPlaceApp.AuthorizeController do
  use RiverPlaceApp.Web, :controller
  alias Oauth2Server.Authenticator

  plug :authenticate_user when action in [:index]

  def index(conn, params) do
    IO.puts "AuthorizeController.index params:#{inspect(params)}"

    # Implicit Grant Request Params
    # response_type=token, client_id=, redirect_uri=null, scope, state

    # Implicit Grant Response params
    # access_token, token_type="bearer?", expires_in=360, scope=scope, state=state

    user = conn.assigns.current_user
    Oauth2Server.Repo.start_link
    oauth_client = Oauth2Server.Repo.get_by(Oauth2Server.OauthClient, random_id: params["client_id"])
    {:ok, oauth_access_token} = Authenticator.generate_access_token(oauth_client, user)

    token_type = "bearer"
    redirect_uri = "https://pitangui.amazon.com/spa/skill/account-linking-status.html?vendorId=M3DGPNXN6KNV76"
    url = "#{redirect_uri}&access_token=#{oauth_access_token.token}&token_type=#{token_type}&expires_in=360&scope=#{params["scope"]}&state=#{params["state"]}"
    IO.puts "Redirecting auth to #{url}"
    redirect(conn, external: url)
  end

end
