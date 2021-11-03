defmodule BowlingWeb.PageController do
  use BowlingWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
