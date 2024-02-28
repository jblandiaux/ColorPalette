defmodule TestWebscrappingWeb.PageController do
  use TestWebscrappingWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def index(conn, _params) do
    render(conn, :index)
  end

  def analyze(conn, _params) do
    # Your logic here
    render(conn, :color_results, layout: false)
  end

  def form(conn, _params) do
    csrf_token = Phoenix.Controller.get_csrf_token()
    render(conn, :form, csrf_token: csrf_token, layout: false)
  end

  def submit(conn, %{"sample_input" => sample_input}) do
    results = ColorAnalysisOrchestrator.analyze_site_colors(sample_input)
    render(conn, :results, results: results, layout: false)
  end
end
