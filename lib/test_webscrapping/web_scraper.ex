defmodule TestWebscrapping.WebScraper do

  def fetch(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to fetch. Status code: #{status_code}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error: #{reason}"}
    end
  end

  def fetch_and_parse(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_html(body)
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to fetch. Status code: #{status_code}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp parse_html(html) do
    # Utilisez Floki pour analyser le HTML et extraire les informations
    # Par exemple, trouver tous les liens dans le document
    images = Floki.find(html, "img")
    |> Enum.map(fn element -> Floki.attribute(element, "src") end)
    |> Enum.filter(&(&1 != "")) # Filtrer les src vides

    {:ok, images}
  end
end
