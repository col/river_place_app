defmodule RiverPlaceApp.ApiAiController do
  use RiverPlaceApp.Web, :controller
  require Logger

  def webhook(conn, params) do
    Logger.debug("Api.ai WebHook - Params: #{inspect(params)}")
    conn
      |> put_resp_content_type("application/json")
      |> send_resp 200, Poison.encode!(%{message: params["message"]})
  end

end
