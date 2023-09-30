defmodule Stocks.DB do
  import Stocks.Utils

  alias Stocks.DB.FileServer
  alias Stocks.Models.Binance

  @home_dir Application.compile_env(:stocks, :home_dir)
  @db_dir "stock_db"

  def drop(model) when is_struct(model) do
    model
    |> path_to_db()
    |> File.rm_rf!()
  end

  def open_append(model) when is_struct(model) do
    model |> path_to_file() |> open_append()
  end

  def open_append(file_path) when is_binary(file_path) do
    :ok = ensure_file_exists(file_path)
    File.open!(file_path, [:binary, :append])
  end

  defp ensure_file_exists(file_path) do
    file_path
    |> Path.dirname()
    |> File.mkdir_p!()
  end

  def append(%Binance.Futures.Trade{} = trade) do
    case Binance.Futures.Trade.changeset(trade) do
      {:ok, changeset} ->
        trade
        |> FileServer.get_fd()
        |> IO.binwrite(changeset)

        {:ok, changeset}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def path_to_db(model) when is_struct(model) do
    Enum.join(
      [
        @home_dir || System.user_home!(),
        @db_dir,
        Enum.join([model.exchange, model.market, model.type], "/")
      ],
      "/"
    )
  end

  def path_to_file(model) do
    model.timestamp_ms
    |> chunk_name(model.type)
    |> path_to_file(model)
  end

  def path_to_file(file_name, model) when is_struct(model) do
    Enum.join([path_to_db(model), file_name], "/")
  end

  defp chunk_name(timestamp, type) do
    timestamp
    |> DateTime.from_unix!(:millisecond)
    |> DateTime.to_date()
    |> Date.to_string()
    |> Kernel.<>(".#{type}")
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
