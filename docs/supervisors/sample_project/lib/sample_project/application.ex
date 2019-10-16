defmodule SampleProject.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: SampleProject.Worker.start_link(arg)
      {SampleProject.Demo, [id: :demo_id, name: :demo, args: []]},
      {SampleProject.Demo, [id: :demo_id2, name: :demo2, args: []]}
      # %{
      #   id: :demo_id,
      #   start: {SampleProject.Demo, :start_link, []}
      # }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SampleProject.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
