
defmodule User do
  @enforce_keys [:user_name, :email]
  defstruct [:user_name, :email]
end

defmodule Message do
  @enforce_keys [:user_name, :content, :timestamp]
  defstruct [:user_name, :content, :timestamp]

  def new(user_name, content) do
    %__MODULE__{
      user_name: user_name,
      content: content,
      timestamp: Time.utc_now()
    }
  end
end

defmodule Room do
  @enforce_keys [:name, :whitelist, :messages]
  defstruct [:name, :whitelist, messages: []]
  @type t() :: %__MODULE__{name: String.t(), whitelist: [String.t()] | :public, messages: [String.t()]}

  def new_public_room(name) do
    %__MODULE__{name: name, whitelist: :public, messages: []}
  end

  def new_private_room(name, whitelist) when is_list(whitelist) do
    %__MODULE__{name: name, whitelist: whitelist, messages: []}
  end

  def new_private_chat(user_a, user_b) do
    %__MODULE__{name: private_chat_key(user_a, user_b), whitelist: [user_a, user_b], messages: []}
  end

  def private_chat_key(a, b) do
    if a < b, do: {a, b}, else: {b, a}
  end

  def push_message(%__MODULE__{messages: messages} = chat, new_message) do
    %{ chat | messages: [new_message|messages] }
  end
end

defmodule State do
  @enforce_keys [:users, :rooms]
  defstruct users: %{}, rooms: %{}

  def user_registered?(%__MODULE__{users: users}, user_name), do: Map.has_key?(users, user_name)
  def put_user(%__MODULE__{users: users} = state, %User{user_name: user_name} = user) do
    %{ state | users: Map.put(users, user_name, user)}
  end

  def room_exists?(%__MODULE__{rooms: rooms}, room_name) do
    Map.has_key?(rooms, room_name)
  end

  def permitted_to_join?(%__MODULE__{rooms: rooms}, user_name, room_name) do
    room_map = Map.get(rooms, room_name)
    case Map.get(room_map, :permissions) do
      :public -> true
      :private ->
        if user_name in Map.get(room_map, :whitelist), do: true, else: false
      _ -> false
    end
  end

  def get_room(%__MODULE__{rooms: rooms}, room_name), do: Map.get(rooms, room_name)

  def put_room(%__MODULE__{rooms: rooms} = state, room_name, %Room{} = room) do
    %{ state | rooms: Map.put(rooms, room_name, room) }
  end

  def update_room(%__MODULE__{rooms: rooms} = state, room_name, default_room, f) do
    room =
      if Map.has_key?(rooms, room_name) do
        f.(rooms[room_name])
      else
        f.(default_room)
      end
    %{ state | rooms: Map.put(rooms, room_name, room) }
  end

  def update_room!(%__MODULE__{rooms: rooms} = state, room_name, f) do
    %{ state | rooms: Map.update!(rooms, room_name, f) }
  end
end

defmodule ChatServer do
  use GenServer

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    initial_state = %State{
      rooms: %{
        "general" => Room.new_public_room("general"),
        "elixir" => Room.new_private_room("elixir", ["doga"]),
        Room.private_chat_key("doga", "nathan") =>
          Room.new_private_chat("doga", "nathan")
          |> Room.push_message(Message.new("doga", "how are you?"))
          |> Room.push_message(Message.new("nathan", "i am good. how about yourself?"))
          |> Room.push_message(Message.new("doga", "what is good? I don't know english"))
          |> Room.push_message(Message.new("nathan", "eggplant"))
      },
      users: %{}
    }
    {:ok, initial_state}
  end

  def handle_call({:register, {user_name, email}}, _from, state) do
    if State.user_registered?(state, user_name) do
      {:reply, :already_registered, state}
    else
      state = State.put_user(state, %User{user_name: user_name, email: email})
      {:reply, :ok, state}
    end
  end

  def handle_call({:send_message, {room_name, user_name, content}}, _from, state) do
    if State.room_exists?(state, room_name) do
      message = Message.new(user_name, content)
      state = State.update_room!(state, room_name, &Room.push_message(&1, message))
      {:reply, state, state}
    else
      {:reply, :room_does_not_exist, state}
    end
  end

  def handle_call({:join_room, {room_name, user_name}}, _from, state) do
    cond do
      not State.user_registered?(state, user_name) -> {:reply, :user_not_registered, state}
      not State.room_exists?(state, room_name) -> {:reply, :room_does_not_exist, state}
      not State.permitted_to_join?(state, user_name, room_name) -> {:reply, :permission_denied, state}
      true -> {:reply, State.get_room(state, room_name), state}
    end
  end

  def handle_call({:send_private_message, {from_user, to_user, message}}, _from, state) do
    message = Message.new(to_user, message)
    if State.user_registered?(state, from_user) and State.user_registered?(state, to_user) do
      chat_key = Room.private_chat_key(from_user, to_user)

      state =
        State.update_room(state, chat_key, Room.new_private_chat(from_user, to_user),
          &Room.push_message(&1, message))
      {:reply, {:ok, state}, state}
    else
      {:reply, :invalid_user, state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
