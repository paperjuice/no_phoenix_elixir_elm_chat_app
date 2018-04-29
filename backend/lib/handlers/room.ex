defmodule Backend.Handlers.Room do

  def init(req, state) do

    {:cowboy_socket, req, state}
  end
end
