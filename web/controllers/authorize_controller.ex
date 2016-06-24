defmodule RiverPlaceApp.AuthorizeController do
  use RiverPlaceApp.Web, :controller

  alias Oauth2Server.Authenticator

  def index(conn, params) do
    # IO.puts inspect(params)
    # render conn, "index.html"
    IO.puts "AuthorizeController.index params:#{inspect(params)}"
    
    user = conn.assigns.current_user

    oauth_params = %{
      "client_id" => params["client_id"],
      "secret" => "kX6MTpJe5DlmiDrxQEhTp_oWwIyt8sR5uC2TLDpu",
      "grant_type" => "password",
      "email" => user.email,
      "password" => "111111"
    }
    IO.puts "Authenticator.validate #{inspect(oauth_params)}"
    res = Authenticator.validate(oauth_params)

    case res.code do
      200 ->
        json conn, %{access_token: res.access_token, refresh_token: res.refresh_token, expiration: res.expires_at}
      400 ->
        conn |> put_status(400) |> json(%{"message": res.message})
      nil ->
        conn |> put_status(400) |> json(%{"message": "Invalid oauth credentials."})
    end
  end

end
