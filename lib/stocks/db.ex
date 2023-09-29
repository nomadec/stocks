defmodule Stocks.DB do
  import Stocks.Utils

  alias Stocks.Models.Binance

  @db_dir "stock_db"

  def drop(model) when is_struct(model) do
    model
    |> path_to_db()
    |> File.rm_rf!()
  end

  def append(%Binance.Futures.Trade{} = trade) do
    path_to_file =
      trade.timestamp_ms
      |> chunk_name(trade.type)
      |> path_to_file(trade)

    :ok = ensure_file_exists(path_to_file)

    fd = File.open!(path_to_file, [:binary, :append])

    case Binance.Futures.Trade.changeset(trade) do
      {:ok, changeset} ->
        IO.binwrite(fd, changeset)
        {:ok, changeset}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp chunk_name(timestamp, type) do
    timestamp
    |> DateTime.from_unix!(:millisecond)
    |> DateTime.to_date()
    |> Date.to_string()
    |> Kernel.<>(".#{type}")
  end

  def path_to_db(model) when is_struct(model) do
    Enum.join(
      [
        System.user_home!(),
        @db_dir,
        Enum.join([model.exchange, model.market, model.type], "/")
      ],
      "/"
    )
  end

  def path_to_file(file_name, model) when is_struct(model) do
    Enum.join([path_to_db(model), file_name], "/")
  end

  defp ensure_file_exists(path_to_file) do
    path_to_file
    |> Path.dirname()
    |> File.mkdir_p!()
  end

  def read(%Binance.Futures.Trade{} = model, %Date{} = from_date, %Date{} = to_date) do
    read(model, to_unix(from_date), to_unix(to_date))
  end

  def read(model, from_unix_ms, to_unix_ms)
      when is_struct(model) and is_integer(from_unix_ms) and is_integer(to_unix_ms) do
    from_unix_ms
    |> chunk_name(model.type)
    |> path_to_file(model)
    |> File.read()
  end
end
