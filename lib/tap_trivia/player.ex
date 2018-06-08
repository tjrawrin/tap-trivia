defmodule TapTrivia.Player do
  @enforce_keys [:name, :color, :id]
  defstruct [:name, :color, :id]

  alias TapTrivia.Player

  @doc """
  Creates a player with the given `name`, `color`, and `id`.
  """
  def new(name, color) do
    time =
      :os.system_time(:millisecond)
      |> to_string()

    random_id =
      (time <> name <> color)
      |> Base.encode64()

    %Player{name: name, color: color, id: random_id}
  end
end
