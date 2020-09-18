defmodule ChatTest do
  def test() do
    {:ok, server} = ChatServer.start_link()

    # GenServer.cast(server, {:register,{"doga", "doga@doga"}})
    # IO.inspect GenServer.call(server, :get_state)

    # GenServer.cast(server, {:register,{"doga", "doga@doga"}})
    # IO.inspect GenServer.call(server, :get_state)

    # GenServer.cast(server, {:register,{"nathan", "nathan@nathan"}})
    # IO.inspect GenServer.call(server, :get_state)

    # GenServer.cast(server, {:send_message,{"general", "doga", "Hi, my name is Doga!"}})
    # IO.inspect GenServer.call(server, :get_state)

    # GenServer.cast(server, {:send_message, {"elixir", "doga", "My favorite language is Elixir."}})
    # IO.inspect GenServer.call(server, :get_state)

    IO.inspect GenServer.call(server, {:register, {"doga", "doga@doga"}})
    IO.inspect GenServer.call(server, {:register, {"doga", "doga@doga"}})
    IO.inspect GenServer.call(server, {:register,{"nathan", "nathan@nathan"}})
    IO.inspect GenServer.call(server, {:send_message,{"general", "doga", "Hi, my name is Doga!"}})
    IO.inspect GenServer.call(server, {:send_message, {"elixir", "doga", "My favorite language is Elixir."}})
    IO.inspect GenServer.call(server, {:send_message, {"random", "doga", "My favorite language is Elixir."}})

    GenServer.call(server, {:send_message, {"elixir", "doga", "I do love Elixir"}})
    GenServer.call(server, {:send_message, {"elixir", "doga", "It's like a nice fine drink."}})
    GenServer.call(server, {:send_message, {"elixir", "doga", "Would you like some elixir too?"}})
    GenServer.call(server, {:send_message, {"elixir", "doga", "I know you want it."}})

    IO.inspect GenServer.call(server, {:join_room, {"elixir", "doga"}})
    IO.inspect GenServer.call(server, {:join_room, {"general", "nathan"}})
    IO.inspect GenServer.call(server, {:join_room, {"elixir", "birsen"}})
    IO.inspect GenServer.call(server, {:join_room, {"general", "birsen"}})

    IO.puts "private messages"
    IO.inspect GenServer.call(server, {:send_private_message, {"doga", "nathan", "hello!"}})
    IO.inspect GenServer.call(server, {:send_private_message, {"nathan", "doga", "whatsssuup!"}})
    IO.inspect GenServer.call(server, {:send_private_message, {"nathan", "doga", "kwell!"}})
    IO.inspect GenServer.call(server, {:send_private_message, {"birsen", "doga", "i'm here too!"}})


    Process.exit(server, :normal)
  end
end
