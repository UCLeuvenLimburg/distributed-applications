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


  def inc(x), do: x + 1
  def dbl(x), do: x * 2
  def sqr(x), do: x * x

  check that: Functions.twice(&inc/1, 0), is_equal_to: 2
  check that: Functions.twice(&inc/1, 1), is_equal_to: 3
  check that: Functions.twice(&inc/1, 2), is_equal_to: 4
  check that: Functions.twice(&dbl/1, 1), is_equal_to: 4
  check that: Functions.twice(&dbl/1, 2), is_equal_to: 8
  check that: Functions.twice(&sqr/1, 1), is_equal_to: 1
  check that: Functions.twice(&sqr/1, 2), is_equal_to: 16
end
