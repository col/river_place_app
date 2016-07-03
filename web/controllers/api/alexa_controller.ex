defmodule RiverPlaceApp.Api.AlexaController do
  use RiverPlaceApp.Web, :controller
  alias Alexa.Request
  require Logger

  def handle_request(conn, params) do
    request = Request.from_params(params)
    response = Alexa.handle_request(request)
    Logger.debug "Response = #{Poison.encode!(response)}"
    conn = send_resp(conn, 200, Poison.encode!(response))
    conn = %{conn | resp_headers: [{"content-type", "application/json"}]}
    conn
  end

  def mock_request(conn, params) do
    {:ok, request} = File.read("test/data/#{params["type"]}_request.json")
    mock_params = Poison.decode!(request)
    handle_request(conn, mock_params)
  end

end
