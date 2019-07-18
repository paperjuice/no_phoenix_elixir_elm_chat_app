defmodule Backend.Handlers.Chat do
  use GenServer

  def init(req, state) do
    {:cowboy_websocket, req, state}
  end

  def websocket_init(state) do
    store_connection(self())
    |> IO.inspect(label: HELLO)

    {:ok, state}
  end

  def websocket_handle({:text, json_request}, state) do
object = Poison.decode!(json_request)

    conns = get_connections()

    for pid <- conns do
      IO.puts( "#{inspect(pid)}")
    end

    response =
    %{
      "name" => object["name"],
      "msg" => object["msg"]
    }
    |> Poison.encode!()
    |> IO.inspect(label: Merge)

    for pid <- conns do
      if pid != self() do
        send(pid, response)
      end
    end

    {:reply, {:text, response}, state}
  end


  def websocket_info( text, state) do
    IO.inspect("info")
    {:reply, {:text, text}, state}
  end

  ### GenServer ###
  def init_genserver do
    GenServer.start_link(__MODULE__, {:connections, []}, [name: :connections])
  end

  def init({:participants, state}) do
    {:ok, state}
  end
  def init({:connections, state}) do
    {:ok, state}
  end



### Connections  ###
  def store_connection(pid) do
    GenServer.cast(:connections, {:store, pid})
  end

  def get_connections do
    GenServer.call(:connections, :get)
  end

  def handle_cast({:store,  pid}, state) do
    state =
      Enum.filter(state, fn pid ->
        Process.alive?(pid)
      end)

    {:noreply, [pid | state]}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
