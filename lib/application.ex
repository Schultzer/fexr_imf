defmodule FexrImf.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(ConCache, [[ttl_check: :timer.seconds(1), ttl: :timer.seconds(450)], [name: :imf]],[ id: :imf, modules: [ConCache]])
    ]

    opts = [strategy: :one_for_one, name: FexrImf.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
