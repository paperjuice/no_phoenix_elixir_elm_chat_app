defmodule Backend.Handlers.Chat do

  use GenServer

  def init(req, state) do
    {:cowboy_websocket, req, state}
  end

  def websocket_init(state) do
    store_connection(self())

    {:ok, state}
  end


  def websocket_handle({:text, message}, state) do
    broadcast_message(message)
    {:ok, state}
  end


  def websocket_info(text, state) do
    {:reply, {:text, text}, state}
  end


  defp broadcast_message(message) do
    connections = get_connections()

    Enum.each(connections, fn conn ->
      send(conn, message)
    end)
  end


  #### GenServer ####
  def init_genserver() do
    GenServer.start_link(__MODULE__, {:connections, []}, [name: :connections])
  end

  def init({:connections, []}) do
    {:ok, []}
  end

  def store_connection(pid) do
    GenServer.cast(:connections, {:store, pid})
  end

  def get_connections() do
    GenServer.call(:connections, :get)
  end

  def handle_cast({:store, pid}, state) do
    state =
      Enum.filter(state, fn pid ->
        Process.alive?(pid)
      end)

    {:noreply, [pid|state]}
  end
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
