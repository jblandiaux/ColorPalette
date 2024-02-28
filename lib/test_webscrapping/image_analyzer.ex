defmodule TestWebscrapping.ImageAnalyzer do
  use Rustler, otp_app: :test_webscrapping, crate: "ok"

  @spec find_dominant_colors(String.t(), integer(), integer(), integer(), float(), integer()) :: {:ok, list({integer(), integer(), integer()})} | {:error, any()}
  def find_dominant_colors(image_path, k, runs, max_iter, converge, seed) do
    # Implementation is not required here, Rustler will link to your Rust NIF
  end
end
