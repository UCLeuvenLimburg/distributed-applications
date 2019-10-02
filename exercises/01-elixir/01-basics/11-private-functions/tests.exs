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

  check that: Math.binomial(1, 0), is_equal_to: 1
  check that: Math.binomial(5, 0), is_equal_to: 1
  check that: Math.binomial(1, 1), is_equal_to: 1
  check that: Math.binomial(5, 1), is_equal_to: 5
  check that: Math.binomial(20, 1), is_equal_to: 20
  check that: Math.binomial(5, 2), is_equal_to: 10
  check that: Math.binomial(10, 2), is_equal_to: 45
  check that: Math.binomial(10, 5), is_equal_to: 252
  check that: Math.binomial(100, 50), is_equal_to: 100891344545564193334812497256
end
