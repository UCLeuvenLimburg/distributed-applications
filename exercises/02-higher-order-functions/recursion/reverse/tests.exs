ExUnit.start()

file = System.get_env("DA_TESTFILE") || "student.exs"
Code.load_file(file, __DIR__)


defmodule Tests do
  use ExUnit.Case, async: true

  data = [
    {[], []},
    {[1], [1]},
    {[1, 2], [2, 1]},
    {[1, 2, 3], [3, 2, 1]},
    {[1, 2, 3, 4], [4, 3, 2, 1]},
    {[:x, :y, :z], [:z, :y, :x]},
  ]

  for {input, expected} <- data do
    @input input
    @expected expected

    test "reverse(#{Kernel.inspect(input)}) should return #{Kernel.inspect(expected)}" do
      assert Exercise.reverse(@input) == @expected
    end
  end
end
