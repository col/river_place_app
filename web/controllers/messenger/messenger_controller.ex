defmodule RiverPlaceApp.MessengerController do
  use RiverPlaceApp.Web, :controller
  require Logger

  @verify_token Application.get_env(:river_place_app, :verify_token)
  @page_access_token Application.get_env(:river_place_app, :page_access_token)

  def validate(conn, params) do
    Logger.debug "GET WebHook - Params: #{inspect(params)}"
    conn = put_resp_content_type(conn, "text/html")
    if params["hub.mode"] == "subscribe" && params["hub.verify_token"] == @verify_token do
      send_resp(conn, 200, params["hub.challenge"])
    else
      send_resp(conn, 403, "")
    end
  end

  def webhook(conn, params) do
    Logger.debug "POST WebHook - Params: #{inspect(params)}"
    conn = put_resp_content_type(conn, "application/json")
    send_resp(conn, 200, Poison.encode!(%{message: params["message"]}))
  end

end
