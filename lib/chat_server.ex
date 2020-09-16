
defmodule User do
  @enforce_keys [:username, :email]
  defstruct username: nil, email: nil
end

defmodule Message do
  @enforce_keys [:username, :content, :timestamp]
  defstruct username: nil, content: nil, timestamp: nil
end

defmodule Room do
  @enforce_keys [:name, :messages]
  defstruct name: nil, messages: []
end

defmodule State do
  @enforce_keys [:users, :rooms]
  defstruct users: %{}, rooms: %{}
end

defmodule ChatServer do
  use GenServer
  import User
  import Room
  import Message

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    initial_state = %State{
      rooms: %{
        "general" => %Room{
          name: "general",
          messages: []
        },
        "elixir" => %Room{
          name: "elixir",
          messages: []
        }
      },
      users: %{}
    }
    {:ok, initial_state}
  end

  def handle_cast({:register, {username, email}}, state) do
    if Map.has_key?(state.users, username) do
      {:noreply, state}
    else
      new_state = Map.update(state, :users, [], fn users_map ->
        Map.put(users_map, username, %User{username: username, email: email})
      end)
      {:noreply, new_state}
    end
  end

  def handle_cast({:send_message, {room_name, username, message}}, state) do
    if Map.has_key?(state.rooms, room_name) do
      message = %Message{
        username: username,
        content: message,
        timestamp: Time.utc_now()
      }
      rooms = Map.update!(state.rooms, room_name, fn room ->
        %{room | messages: [message|room.messages]}
      end)
      {:noreply, %{state | rooms: rooms}}
    else
      IO.puts "invalid request"
      {:noreply, state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
