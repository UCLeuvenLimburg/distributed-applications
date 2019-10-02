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
  import Integer


  check that: Grades.remove_na([]), is_equal_to: []
  check that: Grades.remove_na([0]), is_equal_to: [0]
  check that: Grades.remove_na([10]), is_equal_to: [10]
  check that: Grades.remove_na([1, 2, 3]), is_equal_to: [1, 2, 3]
  check that: Grades.remove_na([:na]), is_equal_to: []
  check that: Grades.remove_na([1, :na]), is_equal_to: [1]
  check that: Grades.remove_na([1, :na, 2]), is_equal_to: [1, 2]
  check that: Grades.remove_na([1, :na, 2, :na]), is_equal_to: [1, 2]
  check that: Grades.remove_na([1, :na, 2, :na, 3]), is_equal_to: [1, 2, 3]
  check that: Grades.remove_na([1, :na, 2, :na, :na, 3]), is_equal_to: [1, 2, 3]
  check that: Grades.remove_na([:na, 1, :na, 2, :na, :na, 3]), is_equal_to: [1, 2, 3]
  check that: Grades.remove_na([:na, 1, :na, 2, :na, :na, 3, :na]), is_equal_to: [1, 2, 3]
  check that: Grades.remove_na([:na, 10, :na, 10, :na, :na, 10, 10, :na]), is_equal_to: [10, 10, 10, 10]
end
