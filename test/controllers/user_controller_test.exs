defmodule RiverPlaceApp.UserControllerTest do
  use RiverPlaceApp.ConnCase
  alias RiverPlaceApp.{Repo, User}

  @valid_attrs %{name: "some content", new_password: "some content", username: "some content", email: "test@example.com"}
  @invalid_attrs %{}

  setup config do
    Oauth2Server.Repo.delete_all(Oauth2Server.OauthAccessToken)
    Oauth2Server.Repo.delete_all(Oauth2Server.OauthRefreshToken)
    Oauth2Server.Repo.delete_all(Oauth2Server.OauthClient)
    RiverPlaceApp.Repo.delete_all(RiverPlaceApp.User)

    if config[:logged_in] do
      user = User.registration_changeset(%User{}, @valid_attrs) |> Repo.insert!
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  @tag :logged_in
  test "lists all entries on index", %{conn: conn, user: user} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing users"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, %{ email: @valid_attrs[:email] })
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  @tag :logged_in
  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~ "Show user"
  end

  @tag :logged_in
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  @tag :logged_in
  test "renders form for editing chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag :logged_in
  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
    # user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, %{email: @valid_attrs[:email]})
  end

  @tag :logged_in
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag :logged_in
  test "deletes chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = delete conn, user_path(conn, :delete, user)
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end
end
