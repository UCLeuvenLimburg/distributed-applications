ExUnit.start()

file = System.get_env("DA_TESTFILE") || "student.exs"
Code.load_file(file, __DIR__)


defmodule Tests do
  use ExUnit.Case, async: true

  data = [
    { [0], 0 },
    { [1], 1 },
    { [5], 5 },
    { [1, 5], 5 },
    { [5, 1], 5 },
    { [1, 2, 3, 4], 4 },
    { [1, 2, 4, 3], 4 },
    { [1, 4, 2, 3], 4 },
    { [4, 1, 3, 2], 4 },
  ]

  for { input, expected } <- data do
    @input input
    @expected expected

    test "maximum(#{Kernel.inspect(input)}) should give #{expected}" do
      assert Exercise.maximum(@input) == @expected
    end
  end
end
