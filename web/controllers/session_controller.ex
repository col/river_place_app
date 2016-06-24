defmodule RiverPlaceApp.SessionController do
  use RiverPlaceApp.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"username" => user, "password" => pass}}) do
    case RiverPlaceApp.Auth.login_by_username_and_pass(conn, user, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(external: after_login_url(conn))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password combination") |> render("new.html")
    end
  end

  def after_login_url(conn) do
    case get_session(conn, :requested_url) do
      nil ->
        page_url(conn, :index)
      url ->
        IO.puts "Redirecting to #{url}"
        put_session(conn, :requested_url, nil)
        url
    end
  end

  def delete(conn, _) do
    conn
    |> RiverPlaceApp.Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end

end
