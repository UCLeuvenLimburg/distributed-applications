ExUnit.start()

file = System.get_env("DA_TESTFILE") || "student.exs"
Code.load_file(file, __DIR__)


defmodule Tests do
  use ExUnit.Case, async: true

  data = [
    { [], 0 },
    { [0], 1 },
    { [1], 1 },
    { [1, 1], 2 },
    { [1, 2], 2 },
    { [1, 2, 3], 3 },
    { [1, 1, 1], 3 },
    { [5, 2, 7], 3 },
    { [5, 2, 7, 3, 1], 5 },
  ]

  for { input, expected } <- data do
    @input input
    @expected expected

    test "len(#{Kernel.inspect(input)}) should be #{expected}" do
      assert Exercise.len(@input) == @expected
    end
  end
end
