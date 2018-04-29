defmodule Backend.InitServer do
  alias Backend.Handlers.Login
  alias Backend.Handlers.Room

  def init do
    dispatch = :cowboy_router.compile([
      {:_, [{"/login", Login, []},
            {"/room", Room, []}
            ]
      }
    ])

    {:ok, _} =
      :cowboy.start_clear(:chat_app,
                          [{:port, 9998}],
                          %{env: %{dispatch: dispatch}}
    )
  end
end
