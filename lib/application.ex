defmodule ResuelveBe.Application do
    use Application

    def start( _type, _args)do
        import Supervisor.Spec

        children = [
            supervisor(ProgramStats, [  ])
        ]

        opts = [strategy: :one_for_one, name: ResuelveBe.Supervisor]
        Supervisor.start_link(children, opts)
    end
end