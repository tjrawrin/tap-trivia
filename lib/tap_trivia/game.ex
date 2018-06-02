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
end
