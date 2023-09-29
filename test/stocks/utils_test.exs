defmodule Stocks.UtilsTest do
  use Stocks.DataCase

  alias Stocks.Utils

  describe "to_unix/2" do
    test "transforms elixir DateTime into unix timestamp in milliseconds" do
      assert 1_695_949_507_000 = DateTime.new!(~D[2023-09-29], ~T[01:05:07]) |> Utils.to_unix()
    end

    test "transforms elixir Date into unix timestamp in milliseconds with time as beginning of day" do
      assert 1_695_945_600_000 = Utils.to_unix(~D[2023-09-29])
    end

    test "transforms ISO8601 datetime format string into unix timestamp in milliseconds" do
      assert 1_695_949_507_000 = Utils.to_unix("2023-09-29 01:05:07Z")
    end

    test "transforms ISO8601 date format string into unix timestamp in milliseconds with time as beginning of day" do
      assert 1_695_945_600_000 = Utils.to_unix("2023-09-29")
    end
  end
end
