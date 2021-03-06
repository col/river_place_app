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

  def todays_date do
    date = Timex.format!(Timex.today, "{YYYY}-{0M}-{D}")
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
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"date" => todays_date})
      {:ok, request: request}
    end

    test "should add the date to the session", %{request: request} do
      response = Alexa.handle_request(request)
      assert todays_date = attribute(response, "date")
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

  describe "setting a date more than 7 days in the future" do
    setup tags do
      date = Timex.format!(Timex.shift(Timex.today, days: 8), "{YYYY}-{0M}-{D}")
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"date" => date})
      {:ok, request: request}
    end

    test "should not add the date to the session", %{request: request} do
      response = Alexa.handle_request(request)
      refute attribute(response, "date")
    end

    test "should tell the user they cannot book more than 7 days in advance", %{request: request} do
      response = Alexa.handle_request(request)
      assert "You cannot book more than seven days in advance. Would you like to choose a different date?" = say(response)
    end

    test "should reprompt the user to choose a different date", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Would you like to choose a different date?" = reprompt(response)
    end

    test "should set the question session attribute", %{request: request} do
      response = Alexa.handle_request(request)
      assert "ChooseDifferentTime?" = attribute(response, "question")
    end

    test "should leave the session open", %{request: request} do
      response = Alexa.handle_request(request)
      refute should_end_session(response)
    end
  end

  describe "setting a date in the past" do
    setup tags do
      date = Timex.format!(Timex.shift(Timex.today, days: -1), "{YYYY}-{0M}-{D}")
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"date" => date})
      {:ok, request: request}
    end

    test "should not add the date to the session", %{request: request} do
      response = Alexa.handle_request(request)
      refute attribute(response, "date")
    end

    test "should tell the user they cannot book in the past", %{request: request} do
      response = Alexa.handle_request(request)
      assert "You cannot book a court in the past. Would you like to choose a different date?" = say(response)
    end

    test "should reprompt the user to choose a different date", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Would you like to choose a different date?" = reprompt(response)
    end

    test "should set the question session attribute", %{request: request} do
      response = Alexa.handle_request(request)
      assert "ChooseDifferentTime?" = attribute(response, "question")
    end

    test "should leave the session open", %{request: request} do
      response = Alexa.handle_request(request)
      refute should_end_session(response)
    end
  end

  describe "setting the date as '2016'" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"date" => "2016"})
      {:ok, request: request}
    end

    test "should not add the date to the session", %{request: request} do
      response = Alexa.handle_request(request)
      refute attribute(response, "date")
    end

    test "should tell the user they cannot book in the past", %{request: request} do
      response = Alexa.handle_request(request)
      assert "That's not a valid date. Would you like to choose a different date?" = say(response)
    end

    test "should reprompt the user to choose a different date", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Would you like to choose a different date?" = reprompt(response)
    end

    test "should set the question session attribute", %{request: request} do
      response = Alexa.handle_request(request)
      assert "ChooseDifferentTime?" = attribute(response, "question")
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

    test "should ask when you would like to play", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Ok. When would you like to play?" = say(response)
    end

    test "should leave the session open", %{request: request} do
      response = Alexa.handle_request(request)
      refute should_end_session(response)
    end
  end

  describe "setting a invalid time ie. 'PM'" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"time" => "PM"})
      {:ok, request: request}
    end

    test "should not add the time to the session", %{request: request} do
      response = Alexa.handle_request(request)
      refute attribute(response, "time")
    end

    test "should ask when you would like to play", %{request: request} do
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
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"date" => todays_date, "time" => "07:00"})
      {:ok, request: request}
    end

    test "should tell me the court is not available", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Sorry. 07:00 AM is not available. Would you like to choose a different time?" = say(response)
    end

    test "should reprompt me to choose a different time", %{request: request} do
      response = Alexa.handle_request(request)
      assert "Would you like to choose a different time?" = reprompt(response)
    end

    test "should set the question session attribute", %{request: request} do
      response = Alexa.handle_request(request)
      assert "ChooseDifferentTime?" = attribute(response, "question")
    end

    test "should leave the session open", %{request: request} do
      response = Alexa.handle_request(request)
      refute should_end_session(response)
    end
  end

  describe "setting a time and day when time slot is available" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"date" => todays_date, "time" => "08:00"})
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

  describe "receiving a error from a court booking request" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("CreateBooking", %{"date" => todays_date, "time" => "09:00"})
      {:ok, request: request}
    end

    test "should tell the user they've exceeded the booking limit for the week", %{request: request} do
      response = Alexa.handle_request(request)
      assert "You've exceeded the booking limit for the week. Please try again later." = say(response)
    end

    test "should close the session", %{request: request} do
      response = Alexa.handle_request(request)
      assert should_end_session(response)
    end
  end

  describe "ChooseDifferentTime? - Yes" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("AMAZON.YesIntent", %{}, %{"question": "ChooseDifferentTime?"})
      {:ok, request: request}
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

  describe "ChooseDifferentTime? - No" do
    setup tags do
      request = RiverPlaceSkillTest.create_request("AMAZON.NoIntent", %{}, %{"question": "ChooseDifferentTime?"})
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
end
