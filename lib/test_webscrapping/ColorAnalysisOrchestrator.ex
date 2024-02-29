defmodule ColorAnalysisOrchestrator do
  # Utilise Task pour exécuter des opérations en parallèle
  def analyze_site_colors(url) do
    case TestWebscrapping.WebScraper.fetch_and_parse(url) do
    {:ok, image_paths} ->
        base_url = get_base_url(url) # Obtient l'URL de base
        results = image_paths
          |> List.flatten() # Aplatit la liste de listes en une seule liste
          |> Enum.filter(&(&1 != [])) # Filtre les listes vides.
          |> Enum.filter(&valid_image_url?/1) # Valide l'URL avant de procéder.
          |> Enum.map(&analyze_image_colors_async(base_url,&1))
          |> Enum.map(&Task.await(&1, 15000)) # Attend jusqu'à 15 secondes pour chaque tâche
          |> process_colors_results()
        {:ok, results}


      {:error, reason} ->
        IO.puts("Erreur lors de la récupération des chemins des images")
        {:error, reason}
    end
  end

    defp analyze_image_colors_async(base_url, image_path) do
      Task.async(fn ->
        full_image_path =
        if is_relative_path?(image_path) do
          URI.merge(base_url, image_path) |> URI.to_string()
        else
          image_path
        end
        # IO.inspect(full_image_path, label: "Full path")
        TestWebscrapping.ImageAnalyzer.find_dominant_colors(full_image_path, 5, 10, 100, 0.0, 42)end)
      end


  defp valid_image_url?(url) do
    url =~ ~r/\.jpg$|\.png$|\.jpeg$|/i
  end


  defp is_relative_path?(url) do
    uri = URI.parse(url)
    uri.scheme == nil
  end

  defp get_base_url(url) do
    uri = URI.parse(url)
    URI.to_string(%URI{uri | path: "", query: nil, fragment: nil})
  end

  defp color_distance({r1, g1, b1}, {r2, g2, b2}) do
    :math.sqrt((r2 - r1) * (r2 - r1) + (g2 - g1) * (g2 - g1) + (b2 - b1) * (b2 - b1))
  end

  defp filter_similar_colors(colors, threshold) do
    Enum.reduce(colors, [], fn color, acc ->
      if Enum.any?(acc, &color_distance(&1, color) < threshold), do: acc, else: [color | acc] #si acc est vide, la fonction n'est jamais exécutée et Enum.any return false
    end)
    |> Enum.reverse() # La liste est inversée à la fin pour restaurer l'ordre original.
  end


  defp process_colors_results(results) do
    results
    |> List.flatten() # Aplatit la liste de résultats en une seule liste de tuples RGB.
    |> Enum.uniq() #élimine les doublons.
    |> filter_similar_colors(90)
    #|> determine_main_colors()
  end
end
