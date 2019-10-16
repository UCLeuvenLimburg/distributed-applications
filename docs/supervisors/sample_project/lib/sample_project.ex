defmodule SampleProject.Demo do
  defmodule Args do
    @necessary [:id, :name, :args]
    def verify_has_necessary_args(args) do
      extracted_keys = Enum.map(args, fn {k, _v} -> k end)

      case Enum.all?(@necessary, &(&1 in extracted_keys)) do
        true -> :ok
        false -> raise "Should have :id, :name and :args param!"
      end
    end
  end

  def start_link(name, _args) do
    pid = spawn_link(__MODULE__, :receive_messages, [])
    Process.register(pid, name)
    {:ok, pid}
  end

  def receive_messages() do
    receive do
      :print_pid -> IO.puts("#{inspect(self())}")
      :die -> Process.exit(self(), :kill)
    end

    receive_messages()
  end

  def child_spec(opts) do
    Args.verify_has_necessary_args(opts)

    %{
      id: opts[:id],
      start: {__MODULE__, :start_link, [opts[:name], opts[:args]]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
