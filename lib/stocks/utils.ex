defmodule Stocks.Utils do
  def to_unix(date, unit \\ :millisecond)

  def to_unix(%DateTime{} = datetime, unit) do
    datetime
    |> DateTime.to_unix(unit)
  end

  def to_unix(%Date{} = date, unit) do
    date
    |> DateTime.new!(~T[00:00:00])
    |> to_unix(unit)
  end

  def to_unix(date_or_datetime, unit) when is_binary(date_or_datetime) do
    case DateTime.from_iso8601(date_or_datetime) do
      {:ok, %DateTime{} = datetime, _} -> to_unix(datetime, unit)
      {:error, _} -> Date.from_iso8601!(date_or_datetime) |> to_unix(unit)
    end
  end
end
