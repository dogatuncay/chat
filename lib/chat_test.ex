defmodule ChatTest do
  def test() do
    {:ok, server} = ChatServer.start_link()

    # GenServer.cast(server, {:register,{"bob", "bob@bob"}})
    # IO.inspect GenServer.call(server, :get_state)

    # GenServer.cast(server, {:register,{"bob", "bob@bob"}})
    # IO.inspect GenServer.call(server, :get_state)

    # GenServer.cast(server, {:register,{"alice", "alice@alice"}})
    # IO.inspect GenServer.call(server, :get_state)

    # GenServer.cast(server, {:send_message,{"general", "bob", "Hi, my name is bob!"}})
    # IO.inspect GenServer.call(server, :get_state)

    # GenServer.cast(server, {:send_message, {"elixir", "bob", "My favorite language is Elixir."}})
    # IO.inspect GenServer.call(server, :get_state)

    IO.inspect GenServer.call(server, {:register, {"bob", "bob@bob"}})
    IO.inspect GenServer.call(server, {:register, {"bob", "bob@bob"}})
    IO.inspect GenServer.call(server, {:register,{"alice", "alice@alice"}})
    IO.inspect GenServer.call(server, {:send_message,{"general", "bob", "Hi, my name is bob!"}})
    IO.inspect GenServer.call(server, {:send_message, {"elixir", "bob", "My favorite language is Elixir."}})
    IO.inspect GenServer.call(server, {:send_message, {"random", "bob", "My favorite language is Elixir."}})

    GenServer.call(server, {:send_message, {"elixir", "bob", "I do love Elixir"}})
    GenServer.call(server, {:send_message, {"elixir", "bob", "It's like a nice fine drink."}})
    GenServer.call(server, {:send_message, {"elixir", "bob", "Would you like some elixir too?"}})
    GenServer.call(server, {:send_message, {"elixir", "bob", "I know you want it."}})

    IO.inspect GenServer.call(server, {:join_room, {"elixir", "bob"}})
    IO.inspect GenServer.call(server, {:join_room, {"general", "alice"}})
    IO.inspect GenServer.call(server, {:join_room, {"elixir", "jack"}})
    IO.inspect GenServer.call(server, {:join_room, {"general", "jack"}})

    IO.puts "private messages"
    IO.inspect GenServer.call(server, {:send_private_message, {"bob", "alice", "hello!"}})
    IO.inspect GenServer.call(server, {:send_private_message, {"alice", "bob", "whatsssuup!"}})
    IO.inspect GenServer.call(server, {:send_private_message, {"alice", "bob", "kwell!"}})
    IO.inspect GenServer.call(server, {:send_private_message, {"jack", "bob", "i'm here too!"}})


    Process.exit(server, :normal)
  end
end
