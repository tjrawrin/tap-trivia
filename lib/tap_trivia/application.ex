defmodule TapTrivia.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: TapTrivia.CategoryRegistry},
      TapTrivia.CategorySupervisor
    ]

    opts = [strategy: :one_for_one, name: TapTrivia.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
