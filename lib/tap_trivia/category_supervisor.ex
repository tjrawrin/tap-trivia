defmodule TapTrivia.CategorySupervisor do
  @moduledoc """
  A supervisor that starts and monitors `CategoryCache` processes.
  """

  use Supervisor

  alias TapTrivia.CategoryCache

  # Client (Public) Interface

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Server (Private) Interface

  @impl true
  def init(:ok) do
    children = [
      start_cache("video-games", "video_games.csv"),
      start_cache("states", "states.csv")
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  # Private

  defp start_cache(category_name, file_name) do
    %{
      id: category_name,
      start: {CategoryCache, :start_link, [category_name, file_name]}
    }
  end
end
