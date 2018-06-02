defmodule TapTrivia.GameCardOption do
  @enforce_keys [:option]
  defstruct [:option, :correct]

  alias TapTrivia.GameCardOption

  @doc """
  Creates an option from the given string.
  """
  def new(option, index) do
    case index do
      0 -> %GameCardOption{option: option, correct: true}
      _ -> %GameCardOption{option: option, correct: false}
    end
  end

  @doc """
  Creates an option from the given string.
  """
  def from_option({option, index}) do
    GameCardOption.new(option, index)
  end
end
