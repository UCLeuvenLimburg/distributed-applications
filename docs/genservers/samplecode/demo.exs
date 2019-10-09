defmodule Demo do
  require IEx

  def debug_in_fuction() do
    xs = [1, 2, 3]
    IEx.pry()
    xs_mapped = Enum.map(xs, &(&1 * 2))
    IEx.pry()
    {higher, _lower} = Enum.split_with(xs_mapped, &(&1 > 5))
    IEx.pry()
  end
end

defmodule T do
  use GenServer
  require Logger

  def start do
    :timer.sleep(3000)
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.warn("#{inspect(self())}")
    {:ok, :ok}
  end

  def handle_info(:inspect, s) do
    Logger.warn("#{inspect(self())}")
    {:noreply, s}
  end
end
