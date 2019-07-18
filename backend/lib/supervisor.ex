defmodule Backend.Supervisor do
  use Application
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do

    children = [__MODULE__]
    Supervisor.init(children, strategy: :one_for_one)
  end


  def start(_type, _args) do
    Backend.InitServer.init()
    Backend.Handlers.Chat.init_genserver()
  end
end
