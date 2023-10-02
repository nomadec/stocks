defmodule Stocks.Models.Binance.Futures.TradeTest do
  use ExUnit.Case
  alias Stocks.Models.Binance.Futures.Trade

  test "creates a new trade with default values" do
    trade = %Trade{}

    assert trade.id == nil
    assert trade.pair == nil
    assert trade.price == nil
    assert trade.qty == nil
    assert trade.timestamp_ms == nil
    assert trade.is_buyer_maker == nil

    assert trade.exchange == "binance"
    assert trade.market == "futures"
    assert trade.type == "trades"
  end

  test "changeset/1 returns correct binary data" do
    trade = %Trade{
      id: 1001,
      pair: "BTCUSDT",
      price: 27030.4,
      qty: 0.25,
      # Friday, September 29, 2023 6:55:02 AM
      timestamp_ms: 1_695_970_502_000,
      is_buyer_maker: true
    }

    assert {:ok, changeset} = Trade.changeset(trade)
    assert changeset == "1695970502000,27030.4,0.25,1\n"
  end
end
