defmodule ChatTest do
  def test() do
    {:ok, server} = ChatServer.start_link()

    GenServer.cast(server, {:register,{"doga", "doga@doga"}})
    IO.inspect GenServer.call(server, :get_state)

    GenServer.cast(server, {:register,{"doga", "doga@doga"}})
    IO.inspect GenServer.call(server, :get_state)

    GenServer.cast(server, {:register,{"nathan", "nathan@nathan"}})
    IO.inspect GenServer.call(server, :get_state)


    GenServer.cast(server, {:send_message,{"general", "doga", "Hi, my name is Doga!"}})
    IO.inspect GenServer.call(server, :get_state)

    GenServer.cast(server, {:send_message, {"elixir", "doga", "My favorite language is Elixir."}})
    IO.inspect GenServer.call(server, :get_state)

    # GenServer.cast(server, {:send_message, {"elixir", "What is your favorite language?."}})
    # IO.inspect GenServer.call(server, :get_state)

    # GenServer.cast(server, {:send_message, {"brah", "Hey brah!"}})
    # IO.inspect GenServer.call(server, :get_state)

    Process.exit(server, :normal)
  end
end
