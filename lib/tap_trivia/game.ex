defmodule TapTrivia.Game do
  @enforce_keys [:cards]
  defstruct cards: nil, scores: %{}, winner: nil

  alias TapTrivia.{CategoryCache, GameCard, Game}

  @doc """
  Creats a game with a set `amount` of questions taken randomly
  from the given list of `trivia` questions.
  """
  def new(category_name, amount) do
    questions = CategoryCache.get_questions(category_name)
    Game.create(questions, amount)
  end

  @doc """
  Creats a game with a set `amount` of questions taken randomly
  from the given list of `trivia` questions.
  """
  def create(questions, amount) do
    cards =
      questions
      |> Enum.shuffle()
      |> Enum.take(amount)
      |> Enum.with_index()
      |> Enum.map(&GameCard.from_question(&1))

    %Game{cards: cards}
  end

  @doc """
  Marks the current card for the given `player` when answered correctly,
  and updates the scores.
  """
  def mark(game, player, option_index) do
    card = Game.current_card(game)

    game
    |> update_card_with_mark(card, player, option_index)
    |> update_scores()
    |> assign_winner_if_last_card(card)
  end

  @doc """
  Returns the first game card that has an `answered_by` field of `nil`. Starts
  at the beginning of the list of cards.
  """
  def current_card(game) do
    game.cards
    |> Enum.reject(fn card -> card.answered_by != nil end)
    |> List.first()
  end

  # Private

  defp update_card_with_mark(game, card, player, option_index) do
    new_cards =
      game.cards
      |> Enum.map(&mark_card_having_index(&1, card.index, player, option_index))

    %{game | cards: new_cards}
  end

  defp mark_card_having_index(card, card_index, player, option_index) do
    with true <- card.index == card_index,
         true <- Enum.at(card.options, option_index).correct == true do
      %GameCard{card | answered_by: player}
    else
      false -> card
    end
  end

  defp update_scores(game) do
    new_scores =
      game.cards
      |> Enum.reject(&is_nil(&1.answered_by))
      |> Enum.map(fn card -> {card.answered_by, card.points} end)
      |> Enum.reduce(%{}, fn {answered_by, points}, scores ->
        Map.update(scores, answered_by, points, &(&1 + points))
      end)

    %{game | scores: new_scores}
  end

  defp assign_winner_if_last_card(game, card) do
    with true <- last_card?(game.cards, card.index),
         0 <- Enum.count(game.cards, &is_nil(&1.answered_by)) do
      %{game | winner: find_winner(game)}
    else
      _ -> game
    end
  end

  defp last_card?(cards, card_index) do
    length(cards) - 1 == card_index
  end

  defp find_winner(game) do
    game.scores
    |> Enum.max_by(fn {_, v} -> v end)
  end
end
