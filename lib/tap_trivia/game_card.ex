defmodule TapTrivia.GameCard do
  @enforce_keys [:question, :options]
  defstruct question: nil, options: nil, points: 100, answered_by: nil, index: nil

  alias TapTrivia.{GameCard, GameCardOption}

  @doc """
  Creates a card from the given `question` and `options`.
  """
  def new(question, options, index) do
    new_options =
      options
      |> Enum.with_index()
      |> Enum.map(&GameCardOption.from_option(&1))
      |> Enum.shuffle()

    %GameCard{question: question, options: new_options, index: index}
  end

  @doc """
  Creates a card from the given map with `:question` and `:options` keys.
  """
  def from_question({%{question: question, options: options}, index}) do
    GameCard.new(question, options, index)
  end
end
