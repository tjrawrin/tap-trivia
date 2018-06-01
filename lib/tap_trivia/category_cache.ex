defmodule TapTrivia.CategoryCache do
  @moduledoc """
  A process that loads a collection of trivia questions from an external source
  and caches them for expedient access. The cache is automatically refreshed
  every hour.
  """

  use GenServer

  @refresh_interval :timer.minutes(60)

  # Client (Public) Interface

  def start_link(category_name, file_name) do
    GenServer.start_link(
      __MODULE__,
      {:ok, category_name, file_name},
      name: via_tuple(category_name)
    )
  end

  def get_questions(category_name) do
    GenServer.call(via_tuple(category_name), :get_questions)
  end

  def force_refresh(category_name, file_name) do
    GenServer.cast(via_tuple(category_name), {:refresh, category_name, file_name})
  end

  # Server (Private) Interface

  @impl true
  def init({:ok, category_name, file_name}) do
    state = load_questions(file_name)
    schedule_refresh(category_name, file_name)
    {:ok, state}
  end

  @impl true
  def handle_call(:get_questions, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:refresh, category_name, file_name}, _state) do
    state = load_questions(file_name)
    schedule_refresh(category_name, file_name)
    {:noreply, state}
  end

  @impl true
  def handle_info({:refresh, category_name, file_name}, _state) do
    state = load_questions(file_name)
    schedule_refresh(category_name, file_name)
    {:noreply, state}
  end

  # Private

  defp schedule_refresh(category_name, file_name) do
    Process.send_after(
      category_pid(category_name),
      {:refresh, category_name, file_name},
      @refresh_interval
    )
  end

  defp load_questions(file_name) do
    TapTrivia.File.parse_file(file_name)
  end

  defp via_tuple(category_name) do
    {:via, Registry, {TapTrivia.CategoryRegistry, category_name}}
  end

  defp category_pid(category_name) do
    category_name
    |> via_tuple()
    |> GenServer.whereis()
  end
end
