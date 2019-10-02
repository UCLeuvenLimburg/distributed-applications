defmodule Setup do
  @script "shared.exs"

  def setup(directory \\ ".") do
    path = Path.join(directory, @script)

    if File.exists?(path) do
      Code.require_file(path)
      Shared.setup(__DIR__)
    else
      setup(Path.join(directory, ".."))
    end
  end
end

Setup.setup


defmodule Tests do
  use ExUnit.Case, async: true
  import Shared

  check that: Fibonacci.fib(0), is_equal_to: 0
  check that: Fibonacci.fib(1), is_equal_to: 1
  check that: Fibonacci.fib(2), is_equal_to: 1
  check that: Fibonacci.fib(3), is_equal_to: 2
  check that: Fibonacci.fib(4), is_equal_to: 3
  check that: Fibonacci.fib(5), is_equal_to: 5
  check that: Fibonacci.fib(6), is_equal_to: 8
  check that: Fibonacci.fib(7), is_equal_to: 13
end
