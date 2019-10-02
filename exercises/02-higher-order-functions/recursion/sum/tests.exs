ExUnit.start()

file = System.get_env("DA_TESTFILE") || "student.exs"
Code.load_file(file, __DIR__)


defmodule Tests do
  use ExUnit.Case, async: true

  data = [
    { [], 0 },
    { [0], 0 },
    { [1], 1 },
    { [1, 1], 2 },
    { [1, 2], 3 },
    { [1, 2, 3], 6 },
    { [1, 1, 1], 3 },
    { [5, 2, 7], 5 + 2 + 7 },
  ]

  for { input, expected } <- data do
    @input input
    @expected expected

    test "sum(#{Kernel.inspect(input)}) should be #{expected}" do
      assert Sum.sum(@input) == @expected
    end
  end
end
