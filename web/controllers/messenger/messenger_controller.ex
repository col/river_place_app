defmodule RiverPlaceApp.MessengerController do
  use RiverPlaceApp.Web, :controller
  require Logger

  @verify_token Application.get_env(:river_place_app, :verify_token)

  def webhook(conn, params) do
    Logger.debug "WebHook - Params: #{inspect(params)}"
    conn = put_resp_content_type(conn, "text/html")
    if params["hub.mode"] == "subscribe" && params["hub.verify_token"] == @verify_token do
      Logger.debug("Validating webhook");
      send_resp(conn, 200, params["hub.challenge"])
    else
      Logger.error("WebHook failed validation.")
      send_resp(conn, 403, "")
    end
  end
end
