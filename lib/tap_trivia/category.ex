defmodule TapTrivia.Category do
  @names ~w(states video-games)

  @doc """
  Returns a list of names.
  """
  def raw_name_list() do
    @names
  end

  @doc """
  Formats the list of names in a prettier way and returns a list of names.
  """
  def pretty_name_list() do
    @names
    |> Enum.map(fn n ->
      n
      |> String.split("-")
      |> Enum.map(&String.capitalize/1)
      |> Enum.join(" ")
    end)
  end
end
