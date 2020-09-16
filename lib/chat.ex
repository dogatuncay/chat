defmodule Chat do
  use Application

  def start(_, _) do
    strategy = :one_for_all
    children = [
    ]

    Supervisor.start_link(children, strategy: strategy, name: __MODULE__)
  end
end
