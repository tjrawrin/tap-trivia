defmodule TapTrivia.GameSupervisor do
  @moduledoc """
  A supervisor that starts and monitors `GameServer` processes.
  """

  use DynamicSupervisor

  alias TapTrivia.GameServer

  # Client (Public) Interface

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Public

  @doc """
  Starts a `GameServer` with the given `game_id`, `category_name`,
  and `amount`.
  """
  def start_game(game_id, category_name, amount) do
    child_spec = %{
      id: GameServer,
      start: {GameServer, :start_link, [game_id, category_name, amount]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @doc """
  Terminates a `GameServer` process normally. It won't be restarted.
  """
  def stop_game(game_id) do
    :ets.delete(:games_table, game_id)
    child_pid = GameServer.game_pid(game_id)
    DynamicSupervisor.terminate_child(__MODULE__, child_pid)
  end

  # Server (Private) Interface

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
