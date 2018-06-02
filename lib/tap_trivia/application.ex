defmodule TapTrivia.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: TapTrivia.CategoryRegistry},
      {Registry, keys: :unique, name: TapTrivia.GameRegistry},
      TapTrivia.CategorySupervisor,
      TapTrivia.GameSupervisor
    ]

    opts = [strategy: :one_for_one, name: TapTrivia.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
