defmodule TestWebscrapping.Repo do
  use Ecto.Repo,
    otp_app: :test_webscrapping,
    adapter: Ecto.Adapters.Postgres
end
