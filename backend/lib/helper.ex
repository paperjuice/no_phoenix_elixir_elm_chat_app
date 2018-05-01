defmodule Backend.Helper do

  def show_connections(state) do
    for {pid, name} <- state do
      IO.puts("#{inspect(pid)} - #{name}")
    end
  end
end
