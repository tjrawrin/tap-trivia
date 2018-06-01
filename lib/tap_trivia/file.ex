defmodule TapTrivia.File do
  @doc """
  Parses a CSV file of questions, four possible answers, and point values.

  Returns a list of maps with each map containing the following keys:

    * `:question` - the question
    * `:options` - a list of possible answers
  """
  def parse_file(name) do
    "../../data/#{name}"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ";"))
    |> Enum.map(fn [question | options] ->
      %{
        question: question,
        options: options
      }
    end)
  end
end
