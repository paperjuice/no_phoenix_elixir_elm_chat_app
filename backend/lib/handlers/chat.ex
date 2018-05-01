defmodule Backend.Handlers.Chat do

  use GenServer

  def init(req, state) do

    {:cowboy_websocket, req, state}
  end

  def websocket_init(state) do

    {:ok, state}
  end


  def websocket_handle({:text, json_request}, state) do
    object = Poison.decode!(json_request)

    case object["type"] do
      "register_name" -> store_connection({self(), object["name"]})
      "new_message" -> 
    end

    conns = get_connections()

    for {pid, name} <- conns do
      IO.puts( "#{inspect(pid)} - #{name}")
    end

    response =
    %{
      "msg_type" => "register_name",
      "msg" => object["name"]
    }
    |> Poison.encode!()

    {:reply, {:text, response}, state}
  end


  def websocket_info({:text, _text}, state) do
    IO.inspect("info")
    {:ok, state}
  end



  defp name_unique?(new_name) do
    state = get_connections()

    result =
      Enum.find(state, fn {pid, name} ->
        name  == new_name && Process.alive?(pid)
      end)

    case result do
      nil -> true
      _   -> false
    end
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
  def store_connection({pid, name}) do
    GenServer.cast(:connections, {:store, {pid, name}})
  end

  def get_connections do
    GenServer.call(:connections, :get)
  end

  def handle_cast({:store, {pid, name}}, state) do
    state =
      Enum.filter(state, fn {pid, _name} ->
        Process.alive?(pid)
      end)

    {:noreply, [{pid, name} | state]}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
