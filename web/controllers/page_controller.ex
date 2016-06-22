defmodule RiverPlaceApp.PageController do
  use RiverPlaceApp.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
