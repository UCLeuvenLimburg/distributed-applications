defmodule Functions do
  def fixedpoint(f, x) do
    y = f.(x)

    if x == y, do: x, else: fixedpoint(f, y)
  end
end

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

  check that: Float.round(Math.sqrt(9)), is_equal_to: 3
  check that: Float.round(Math.sqrt(16)), is_equal_to: 4
  check that: Float.round(Math.sqrt(25)), is_equal_to: 5
  check that: Float.round(Math.sqrt(100)), is_equal_to: 10
end
