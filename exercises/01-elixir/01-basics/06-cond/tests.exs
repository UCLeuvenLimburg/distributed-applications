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

  check that: Numbers.sign(1), is_equal_to: 1
  check that: Numbers.sign(2), is_equal_to: 1
  check that: Numbers.sign(5), is_equal_to: 1
  check that: Numbers.sign(100), is_equal_to: 1
  check that: Numbers.sign(0), is_equal_to: 0
  check that: Numbers.sign(-1), is_equal_to: -1
  check that: Numbers.sign(-2), is_equal_to: -1
  check that: Numbers.sign(-5), is_equal_to: -1
  check that: Numbers.sign(-111), is_equal_to: -1
end
