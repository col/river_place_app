defmodule RiverPlaceApp.AuthorizeControllerTest do
  use RiverPlaceApp.ConnCase
  alias RiverPlaceApp.User

  setup tags do
    Oauth2Server.Repo.delete_all(Oauth2Server.OauthClient)
    RiverPlaceApp.Repo.delete_all(RiverPlaceApp.User)

    if tags[:logged_in] do
      conn = assign(conn, :current_user, %User{})
      {:ok, conn: conn}
    else
      :ok
    end
  end

  @tag :logged_in
  test "GET /oauth/authorize", %{conn: conn} do
    %Oauth2Server.OauthClient{
      random_id: "client-id",
      secret: "secret",
      redirect_url: "http://www.redirect.com",
      allowed_grant_types: "whatever"
    } |> Oauth2Server.Repo.insert!

    conn = get conn, "/oauth/authorize", %{
      response_type: "token",
      client_id: "client-id",
      state: "some-state"
    }

    redirect_url = redirected_to(conn)
    assert String.starts_with?(redirect_url, "http://www.redirect.com#access_token=")
    assert String.contains?(redirect_url, "&token_type=Bearer")
    assert String.contains?(redirect_url, "&state=some-state")
  end
end
