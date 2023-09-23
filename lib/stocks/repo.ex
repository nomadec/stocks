defmodule Stocks.Repo do
  use Ecto.Repo,
    otp_app: :stocks,
    adapter: Ecto.Adapters.Postgres
end
