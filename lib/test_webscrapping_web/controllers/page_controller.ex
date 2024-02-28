defmodule TestWebscrappingWeb.PageController do
  use TestWebscrappingWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def analyze(conn, %{"url" => site_url}) do
    # Your logic here
    render(conn, "index.html", site_url: site_url)
  end
end
