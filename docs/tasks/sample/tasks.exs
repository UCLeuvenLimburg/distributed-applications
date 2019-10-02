defmodule Benchmark do
  def measure(function) do
    function
    |> :timer.tc()
    |> elem(0)
    |> Kernel./(1_000_000)
  end
end

defmodule Factorials do
  def calculate(n), do: calculate(n, 1)
  def calculate(1, acc), do: acc
  def calculate(n, acc), do: calculate(n - 1, acc * n)
end

defmodule Triangular do
  def number(n), do: number(n, 0)
  def number(0, acc), do: acc
  def number(n, acc), do: number(n - 1, acc + n)
end

# Synchronous
fn ->
  Factorials.calculate(50_000)
  Triangular.number(50_000 * 10_000)
end
|> Benchmark.measure()

Application.ensure_all_started(:inets)
Application.ensure_all_started(:ssl)

fn ->
  tasks =
    Enum.map(1..200, fn _ ->
      Task.async(fn ->
        :timer.sleep(100)
        :httpc.request(:get, {'http://intranet.ucll.be', []}, [], [])
      end)
    end)

  Task.yield_many(tasks, 60_000)
end
|> Benchmark.measure()

fn ->
  Enum.map(1..200, fn _ ->
    :timer.sleep(100)
    :httpc.request(:get, {'http://intranet.ucll.be', []}, [], [])
  end)
end
|> Benchmark.measure()
