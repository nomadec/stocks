defmodule Stocks.DB.FileServer do
  use GenServer

  alias Stocks.DB

  @file_open_timeout 60_000

  def get_fd(model, file_open_timeout \\ @file_open_timeout) when is_struct(model) do
    case GenServer.whereis(name(model)) do
      nil ->
        {:ok, pid} = start_link(model)

        receive do
          {:file_ready, ^pid} ->
            GenServer.call(pid, {:get_fd, file_open_timeout})
        after
          1000 ->
            {:error, :timeout}
        end

      pid when is_pid(pid) ->
        GenServer.call(pid, {:get_fd, file_open_timeout})
    end
  end

  def start_link(model, timeout \\ @file_open_timeout) when is_struct(model) do
    file_path = DB.path_to_file(model)
    GenServer.start_link(__MODULE__, {file_path, timeout, self()}, name: name(file_path))
  end

  defp name(model) when is_struct(model),
    do: {:via, Registry, {Registry.Stocks, DB.path_to_file(model)}}

  defp name(file_path) when is_binary(file_path),
    do: {:via, Registry, {Registry.Stocks, file_path}}

  @impl true
  def init({file_path, timeout, initiator} = _state) when is_binary(file_path) do
    send(initiator, {:file_ready, self()})
    {:ok, {DB.open_append(file_path), timeout}, timeout}
  end

  @impl true
  def handle_call({:get_fd, timeout}, _from, {fd, default_timeout} = state) do
    {:reply, fd, state, timeout || default_timeout}
  end

  @impl true
  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  # despite documentation states, that no cleanup is needed for File.io_device/0
  # I think it's better to handle it explicitly
  # https://hexdocs.pm/elixir/1.15.6/GenServer.html#c:terminate/2
  @impl true
  def terminate(_reason, {fd, _timeout}) do
    File.close(fd)
    :ok
  end
end
