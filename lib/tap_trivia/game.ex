defmodule TapTrivia.Game do
  @enforce_keys [:cards]
  defstruct cards: nil, scores: %{}, winner: nil

  alias TapTrivia.{GameCard, Game}

  @doc """
  Creats a game with a set `amount` of questions taken randomly
  from the given list of `trivia` questions.
  """
  def new(questions, amount) do
    cards =
      questions
      |> Enum.shuffle()
      |> Enum.take(amount)
      |> Enum.with_index()
      |> Enum.map(&GameCard.from_question(&1))

    %Game{cards: cards}
  end

  @doc """
  Marks the card that has the given `index` for the given `player` when
  answered correctly, and updates the scores.
  """
  def mark(game, card_index, player, option_index) do
    game
    |> update_card_with_mark(card_index, player, option_index)
    |> update_scores()
    |> assign_winner_if_last_card(card_index)
  end

  # Private

  defp update_card_with_mark(game, card_index, player, option_index) do
    new_cards =
      game.cards
      |> Enum.map(&mark_card_having_index(&1, card_index, player, option_index))

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

  defp assign_winner_if_last_card(game, card_index) do
    with true <- last_card?(game.cards, card_index),
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
