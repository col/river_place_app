defmodule RiverPlaceSkillTest do
  use Pavlov.Case
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

  def create_request(intent_name, slot_values \\ %{}, attributes \\ %{}) do
    Request.intent_request("test-app-id", intent_name, nil, slot_values, attributes, "token")
  end

  context "with no existing booking" do
    before do
      RiverPlaceSkillTest.clean_db
      token
    end

    let :user do
      RiverPlaceApp.User.changeset(%RiverPlaceApp.User{}, %{name: "Test", username: "test", email: "test@example.com", new_password: "111111", rp_username: "foo", rp_password: "bar"})
      |> RiverPlaceApp.Repo.insert!
    end

    let :client do
      Oauth2Server.OauthClient.changeset(%Oauth2Server.OauthClient{}, %{random_id: "client-id", secret: "client-secret", allowed_grant_types: "{\"refresh_token\":true, \"password\":true, \"client_credentials\":true}"})
      |> Oauth2Server.Repo.insert!
    end

    let :token do
      Oauth2Server.OauthAccessToken.changeset(%Oauth2Server.OauthAccessToken{}, %{token: "token", expires_at: 1466790237, oauth_client_id: client.id, user_id: user.id})
      |> Oauth2Server.Repo.insert!
    end

    describe "launching the skill" do
      let :request, do: RiverPlaceSkillTest.create_request("CreateBooking")
      subject do: Alexa.handle_request(request)

      it "should respond with a greating" do
        assert "Ok. When would you like to play?" = say(subject)
      end
      it "should leave the session open" do
        refute should_end_session(subject)
      end
    end

    describe "setting a date" do
      let :request, do: RiverPlaceSkillTest.create_request("CreateBooking", %{"date" => "2016-01-01"})
      subject do: Alexa.handle_request(request)

      it "should add the date to the session" do
        assert "2016-01-01" = attribute(subject, "date")
      end
      it "should ask for the time of the booking" do
        assert "What time would you like to play?" = say(subject)
      end
      it "should leave the session open" do
        refute should_end_session(subject)
      end
    end

    describe "setting a time" do
      let :request, do: RiverPlaceSkillTest.create_request("CreateBooking", %{"time" => "18:00"})
      subject do: Alexa.handle_request(request)

      it "should add the time to the session" do
        assert "06:00 PM" = attribute(subject, "time")
      end
      it "should ask for the time of the booking" do
        assert "What day would you like to play?" = say(subject)
      end
      it "should leave the session open" do
        refute should_end_session(subject)
      end
    end

    describe "setting a time and day" do
      before do
        RiverPlaceSkillTest.clean_db
        token
      end
      let :request, do: RiverPlaceSkillTest.create_request("CreateBooking", %{"date" => "2016-01-01", "time" => "07:00"})
      subject do: Alexa.handle_request(request)

      it "should ask for the time of the booking" do
        assert "OK, I've booked Court 1 for you at <say-as interpret-as=\"time\" format=\"hms12\">07:00 AM</say-as>" = say_ssml(subject)
      end
      it "should leave the session open" do
        assert should_end_session(subject)
      end
    end

  end

end
