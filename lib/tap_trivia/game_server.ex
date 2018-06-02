defmodule TapTrivia.GameServer do
  @moduledoc """
  A game server process that holds a `Game` struct as its state.
  """

  use GenServer

  alias TapTrivia.{CategoryCache, Game}

  @timeout :timer.minutes(60)

  # Client (Public) Interface

  def start_link(game_id, category_name, amount) do
    GenServer.start_link(__MODULE__, {game_id, category_name, amount}, name: via_tuple(game_id))
  end

  # Public

  @doc """
  Returns the `pid` of a game process when given a `game_id`.
  """
  def game_pid(game_id) do
    game_id
    |> via_tuple()
    |> GenServer.whereis()
  end

  # Server (Private) Interface

  @impl true
  def init({_, category_name, amount}) do
    questions = CategoryCache.get_questions(category_name)
    game = Game.new(questions, amount)
    {:ok, game, @timeout}
  end

  # Private

  defp via_tuple(game_id) do
    {:via, Registry, {TapTrivia.GameRegistry, game_id}}
  end
end
