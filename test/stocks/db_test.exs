defmodule Stocks.DBTest do
  use Stocks.DataCase

  alias Stocks.DB
  alias Stocks.Models.Binance.Futures.Trade

  setup do
    reset_db()

    %{}
  end

  test "path_to_db/1" do
    path = DB.path_to_db(%Trade{})
    assert String.contains?(path, "/stock_db/binance/futures/trades")
  end

  test "drop/1" do
    model = %Trade{}
    path = DB.path_to_db(model)
    path_to_file = "#{path}/test.txt"

    :ok = File.mkdir_p!(path)
    fd = File.open!(path_to_file, [:binary, :write])
    IO.binwrite(fd, "test data")
    File.close(fd)

    assert [deleted_path, deleted_file] = DB.drop(model)
    assert String.contains?(deleted_path, "/stock_db/binance/futures/trades")
    assert String.contains?(deleted_file, "/stock_db/binance/futures/trades/test.txt")
  end

  test "append/1" do
    trade = %Trade{
      id: 1001,
      pair: "BTCUSDT",
      price: 27030.4,
      qty: 0.25,
      # Friday, September 29, 2023 6:55:02 AM
      timestamp_ms: 1_695_970_502_000,
      is_buyer_maker: true
    }

    assert {:ok, data} = DB.append(trade)
    assert data == "1695970502000,27030.4,0.25,1\n"

    assert {:ok, "1695970502000,27030.4,0.25,1\n"} =
             DB.read(trade, ~D[2023-09-29], ~D[2023-09-29])

    assert {:ok, data} = DB.append(trade)
    assert data == "1695970502000,27030.4,0.25,1\n"

    assert {:ok, "1695970502000,27030.4,0.25,1\n1695970502000,27030.4,0.25,1\n"} =
             DB.read(trade, ~D[2023-09-29], ~D[2023-09-29])
  end

  test "read/1" do
    trade = %Trade{
      id: 1001,
      pair: "BTCUSDT",
      price: 27030.4,
      qty: 0.25,
      # Friday, September 29, 2023 6:55:02 AM
      timestamp_ms: 1_695_970_502_000,
      is_buyer_maker: true
    }

    assert {:ok, "1695970502000,27030.4,0.25,1\n"} = DB.append(trade)

    assert {:ok, "1695970502000,27030.4,0.25,1\n"} =
             DB.read(trade, ~D[2023-09-29], ~D[2023-09-29])
  end

  defp reset_db(model \\ %Trade{}) do
    DB.drop(model)
  end
end
