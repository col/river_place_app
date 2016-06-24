defmodule RiverPlaceApp.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias RiverPlaceApp.Router.Helpers

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user = user_id && repo.get(RiverPlaceApp.User, user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  def login_by_username_and_pass(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(RiverPlaceApp.User, username: username)
    cond do
      user && checkpw(given_pass, user.password) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      IO.puts "Request URL = #{request_url(conn)}"

      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> put_session(:requested_url, request_url(conn))
      |> redirect(to: Helpers.session_path(conn, :new))
      |> halt()
    end
  end

  def request_url(conn) do
    port = if conn.port == 80 do "" else ":#{conn.port}" end
    query = if conn.query_string == "" do "" else "?#{conn.query_string}" end
    "#{conn.scheme}://#{conn.host}#{port}#{conn.request_path}#{query}"
  end

end
