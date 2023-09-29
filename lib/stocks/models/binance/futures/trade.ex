defmodule Stocks.Models.Binance.Futures.Trade do
  use Ecto.Schema
  import Ecto.Changeset
  alias Stocks.Models.Binance.Futures.Trade

  @primary_key false

  embedded_schema do
    field :exchange, :string, default: "binance"
    field :market, :string, default: "futures"
    field :type, :string, default: "trades"

    field :id, :integer
    field :pair, :string
    field :price, :float
    field :qty, :float
    field :timestamp_ms, :integer

    # explanation of :is_buyer_maker field:
    # https://dev.binance.vision/t/trade-data-does-not-specify-if-buyer-or-seller/4451/6
    field :is_buyer_maker, :boolean
  end

  @doc false
  def changeset(%Trade{} = trade, attrs \\ %{}) do
    trade
    |> cast(attrs, [:id, :pair, :price, :qty, :timestamp_ms, :is_buyer_maker])
    |> validate_required([:id, :pair, :price, :qty, :timestamp_ms, :is_buyer_maker])
    |> apply_action(:update)
    |> case do
      {:ok, %__MODULE__{} = trade} ->
        data =
          "#{trade.timestamp_ms}, #{trade.price}, #{trade.qty}, #{if(trade.is_buyer_maker, do: 1, else: 0)}"

        {:ok, data}

      {:error, changeset} ->
        IO.inspect(changeset)
        {:error, changeset}
    end
  end
end
