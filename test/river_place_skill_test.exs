defmodule RiverPlaceSkillTest do
  use ExUnit.Case
  import Alexa.Response
  alias RiverPlaceSkill.Booking
  alias Alexa.Request
  # alias Oauth2Server.{Repo, OauthClient, OauthAccessToken}
  doctest RiverPlaceSkill
  require RiverPlaceMock

  @app_id "test-app-id"

  def clean_db do
    Oauth2Server.Repo.delete_all(Oauth2Server.OauthAccessToken)
    Oauth2Server.Repo.delete_all(Oauth2Server.OauthRefreshToken)
    Oauth2Server.Repo.delete_all(Oauth2Server.OauthClient)
    RiverPlaceApp.Repo.delete_all(RiverPlaceApp.User)
  end

  def create_request(intent_name, slot_values \\ %{}, attributes \\ %{}, token \\ "token") do
    Request.intent_request("test-app-id", intent_name, nil, slot_values, attributes, token)
  end

  def launch_request(token \\ "token") do
    Request.launch_request("test-app-id", nil, token)
  end

  setup tags do
    RiverPlaceSkillTest.clean_db
    user = RiverPlaceApp.User.changeset(%RiverPlaceApp.User{}, %{name: "Test", username: "test", email: "test@example.com", new_password: "111111", rp_username: "foo", rp_password: "bar"})
      |> RiverPlaceApp.Repo.insert!
    client = Oauth2Server.OauthClient.changeset(%Oauth2Server.OauthClient{}, %{random_id: "client-id", secret: "client-secret", allowed_grant_types: "{\"refresh_token\":true, \"password\":true, \"client_credentials\":true}"})
      |> Oauth2Server.Repo.insert!
    token = Oauth2Server.OauthAccessToken.changeset(%Oauth2Server.OauthAccessToken{}, %{token: "token", expires_at: 1466790237, oauth_client_id: client.id, user_id: user.id})
      |> Oauth2Server.Repo.insert!
    :ok
  end


  describe "handle launch when not linked" do
    setup tags do
      request = RiverPlaceSkillTest.launch_request("invalid-token")
      {:ok, request: request}
    end

    test "should tell the user they need to link their account", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Please link to your River Place account using the Alexa app" = say(response)
    end

    test "should respond with a LinkAccount card", %{request: request} do
      response = Alexa.handle_request(request)
      assert %Alexa.Card{type: "LinkAccount", title: "Link Account", content: "You can link your River Place account here"} = card(response)
    end
  end

  describe "handle intent when not linked" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{}, %{}, "invalid-token")
      {:ok, request: request}
    end

    test "should tell the user they need to link their account", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Please link to your River Place account using the Alexa app" = say(response)
    end

    test "should respond with a LinkAccount card", %{request: request} do
      response = Alexa.handle_request(request)
      assert %Alexa.Card{type: "LinkAccount", title: "Link Account", content: "You can link your River Place account here"} = card(response)
    end
  end

  describe "launch request" do
    setup tags do
      request = RiverPlaceSkillTest.launch_request
      {:ok, request: request}
    end

    test "should respond with a greating", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Ok. When would you like to play?" = say(response)
    end

    test "should leave the session open", %{request: request} do
      response = Alexa.handle_request(request)
      refute should_end_session(response)
    end
  end

  describe "start create booking intent" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("CreateBooking")
      {:ok, request: request}
    end

    test "should respond with a greating", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Ok. When would you like to play?" = say(response)
    end

    test "should leave the session open", %{request: request} do
      response = Alexa.handle_request(request)
      refute should_end_session(response)
    end
  end

  describe "asking for help" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("AMAZON.HelpIntent")
      {:ok, request: request}
    end

    test "should respond with a greating", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Ask me to book you a tennis court and tell me the which day and time you'd like to play." = say(response)
    end

    test "should leave the session open", %{request: request} do
      response = Alexa.handle_request(request)
      refute should_end_session(response)
    end
  end

  describe "stop" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("AMAZON.StopIntent")
      {:ok, request: request}
    end

    test "should not say anything", %{request: request} do
      response = Alexa.handle_request(request)
      assert "" == say(response)
    end

    test "should close the session", %{request: request} do
      response = Alexa.handle_request(request)
      assert should_end_session(response)
    end
  end

  describe "cancel" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("AMAZON.CancelIntent")
      {:ok, request: request}
    end

    test "should not say anything", %{request: request} do
      response = Alexa.handle_request(request)
      assert "" == say(response)
    end

    test "should close the session", %{request: request} do
      response = Alexa.handle_request(request)
      assert should_end_session(response)
    end
  end

  describe "setting a date" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"date" => "2016-01-01"})
      {:ok, request: request}
    end

    test "should add the date to the session", %{request: request} do
      response = Alexa.handle_request(request)
      assert "2016-01-01" = attribute(response, "date")
    end

    test "should ask for the time of the booking", %{request: request} do
      response = Alexa.handle_request(request)
      assert "What time would you like to play?" = say(response)
    end

    test "should leave the session open", %{request: request} do
      response = Alexa.handle_request(request)
      refute should_end_session(response)
    end
  end

  describe "setting an empty date" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"date" => ""})
      {:ok, request: request}
    end

    test "should not add the date to the session", %{request: request} do
      response = Alexa.handle_request(request)
      refute attribute(response, "date")
    end

    test "should ask when you'd like to play", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Ok. When would you like to play?" = say(response)
    end

    test "should leave the session open", %{request: request} do
      response = Alexa.handle_request(request)
      refute should_end_session(response)
    end
  end

  describe "setting a time" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"time" => "18:00"})
      {:ok, request: request}
    end

    test "should add the time to the session", %{request: request} do
      response = Alexa.handle_request(request)
      assert "06:00 PM" = attribute(response, "time")
    end

    test "should ask for the day of the booking", %{request: request} do
      response = Alexa.handle_request(request)
      assert "What day would you like to play?" = say(response)
    end

    test "should leave the session open", %{request: request} do
      response = Alexa.handle_request(request)
      refute should_end_session(response)
    end
  end

  describe "setting a empty time" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"time" => ""})
      {:ok, request: request}
    end

    test "should not add the time to the session", %{request: request} do
      response = Alexa.handle_request(request)
      refute attribute(response, "time")
    end

    test "should ask for the time of the booking", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Ok. When would you like to play?" = say(response)
    end

    test "should leave the session open", %{request: request} do
      response = Alexa.handle_request(request)
      refute should_end_session(response)
    end
  end

  describe "setting a time and day when time slot in unavailable" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"date" => "2016-01-01", "time" => "07:00"})
      {:ok, request: request}
    end

    test "should tell me the court is not available", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Sorry. 07:00 AM is not available" = say(response)
    end

    test "should leave the session open", %{request: request} do
      response = Alexa.handle_request(request)
      refute should_end_session(response)
    end
  end

  describe "setting a time and day when time slot is available" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"date" => "2016-01-01", "time" => "08:00"})
      {:ok, request: request}
    end

    test "should tell me the court is not available", %{request: request} do
      response = Alexa.handle_request(request)
      assert "OK, I've booked Court 1 for you at 08:00 AM" = say(response)
    end

    test "should close the session", %{request: request} do
      response = Alexa.handle_request(request)
      assert should_end_session(response)
    end
  end
end
