defmodule RiverPlaceApp.MessengerControllerTest do
  use RiverPlaceApp.ConnCase

  test "GET /messenger/webhook" do
    params = %{
      "hub.mode" => "subscribe",
      "hub.verify_token" => "sample-verify-token",
      "hub.challenge" => "example-challenge"
    }

    conn = get conn, "/messenger/webhook", params
    assert html_response(conn, 200) =~ "example-challenge"
  end

end
