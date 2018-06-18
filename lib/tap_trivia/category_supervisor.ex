defmodule TapTrivia.CategorySupervisor do
  @moduledoc """
  A supervisor that starts and monitors `CategoryCache` processes.
  """

  use Supervisor

  alias TapTrivia.{Category, CategoryCache}

  # Client (Public) Interface

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Server (Private) Interface

  @impl true
  def init(:ok) do
    children = generate_children()

    Supervisor.init(children, strategy: :one_for_one)
  end

  # Private

  defp start_cache(category_name, file_name) do
    %{
      id: category_name,
      start: {CategoryCache, :start_link, [category_name, file_name]}
    }
  end

  defp generate_children() do
    names = Category.raw_name_list()

    names
    |> Enum.map(fn name ->
      start_cache(name, name <> ".csv")
    end)
  end
end
