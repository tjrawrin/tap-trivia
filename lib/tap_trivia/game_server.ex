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

  def mark(game_id, player, option_index) do
    GenServer.call(via_tuple(game_id), {:mark, player, option_index})
  end

  def current_card(game_id) do
    GenServer.call(via_tuple(game_id), :current_card)
  end

  def summary(game_id) do
    GenServer.call(via_tuple(game_id), :summary)
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
  def init({game_id, category_name, amount}) do
    questions = CategoryCache.get_questions(category_name)

    game =
      case :ets.lookup(:games_table, game_id) do
        [] ->
          game = Game.create(questions, amount)
          :ets.insert(:games_table, {game_id, game})
          game

        [{^game_id, game}] ->
          game
      end

    {:ok, game, @timeout}
  end

  @impl true
  def handle_call({:mark, player, option_index}, _from, game) do
    new_game = Game.mark(game, player, option_index)

    :ets.insert(:games_table, {my_game_name(), new_game})

    {:reply, summarize(new_game), new_game, @timeout}
  end

  @impl true
  def handle_call(:current_card, _from, game) do
    game_card = Game.current_card(game)

    {:reply, game_card, game, @timeout}
  end

  @impl true
  def handle_call(:summary, _from, game) do
    {:reply, summarize(game), game, @timeout}
  end

  @impl true
  def handle_info(:timeout, game) do
    {:stop, {:shutdown, :timeout}, game}
  end

  @impl true
  def terminate({:shutdown, :timeout}, _game) do
    :ets.delete(:games_table, my_game_name())
    :ok
  end

  @impl true
  def terminate(_reason, _game), do: :ok

  # Private

  defp via_tuple(game_id) do
    {:via, Registry, {TapTrivia.GameRegistry, game_id}}
  end

  # TODO: Find a way to transform the `game` information to filter out
  # things we don't want to show the client.
  defp summarize(game) do
    game
  end

  defp my_game_name() do
    Registry.keys(TapTrivia.GameRegistry, self()) |> List.first()
  end
end
