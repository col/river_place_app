defmodule RiverPlaceApp.ApiAiControllerTest do
  use RiverPlaceApp.ConnCase

  test "POST /api.ai/webhook" do
    request = "{\"message\": \"hello\"}"
    conn = conn
      |> put_req_header("content-type", "application/json")
      |> post "/api.ai/webhook", request
    assert json_response(conn, 200) == %{"message" => "hello"}
  end

end
