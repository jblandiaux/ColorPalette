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

  def redirect_form(conn, _params) do
    render(conn, :form, layout: false)
  end

  def form(conn, _params) do
    redirect(conn, to: ~p"/redirect_form")
  end

  def submit(conn, %{"sample_input" => sample_input}) do
    case ColorAnalysisOrchestrator.analyze_site_colors(sample_input) do
      {:ok, color_results} ->
        render(conn, :results, results: color_results, layout: false)
        {:error, error_reason} ->
          conn
        |> put_flash(:error, error_reason)
        |> redirect(to: "/form")
      end
  end
end
