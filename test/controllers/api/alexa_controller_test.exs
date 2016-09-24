defmodule RiverPlaceApp.Api.AlexaControllerTest do
  use RiverPlaceApp.ConnCase

  @cert_url "https://s3.amazonaws.com/echo.api/echo-api-cert-3.pem"

  test "POST /api/command" do
    {:ok, request} = File.read("test/data/book_court_request.json")
    {:ok, response} = File.read("test/data/book_court_response.json")

    conn = conn(:post, "/api/command", request)
    |> put_req_header("content-type", "application/json")
    |> put_req_header("signaturecertchainurl", @cert_url)
    |> put_req_header("signature", "success")
    |> RiverPlaceApp.Endpoint.call([])

    actual_response = json_response(conn, 200)
    expected_response = Poison.decode!(response)
    assert actual_response == expected_response
  end

end
