defmodule Backend.InitServer do
  alias Backend.Handlers.Chat

  def init do
    dispatch = :cowboy_router.compile([
      {:_, [{"/chat", Chat, []}]
      }
    ])

    {:ok, _} =
      :cowboy.start_clear(:chat_app,
                          [{:port, 9998}],
                          %{env: %{dispatch: dispatch}}
    )
  end
end
