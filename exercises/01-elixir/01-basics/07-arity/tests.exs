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

  check that: Numbers.maximum(1, 2), is_equal_to: 2
  check that: Numbers.maximum(3, 2), is_equal_to: 3
  check that: Numbers.maximum(1, 5, 2), is_equal_to: 5

  check that: Numbers.maximum(7, 5, 2), is_equal_to: 7
  check that: Numbers.maximum(7, 5, 9), is_equal_to: 9
  check that: Numbers.maximum(7, 10, 9), is_equal_to: 10

  check that: Numbers.maximum(3, 2, 1, 0), is_equal_to: 3
  check that: Numbers.maximum(3, 4, 1, 0), is_equal_to: 4
  check that: Numbers.maximum(3, 4, 7, 0), is_equal_to: 7
  check that: Numbers.maximum(3, 4, 7, 9), is_equal_to: 9
end
