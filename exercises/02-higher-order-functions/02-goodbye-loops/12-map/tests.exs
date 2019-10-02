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


  check that: Grades.to_code([]), is_equal_to: ""
  check that: Grades.to_code([0]), is_equal_to: "C"
  check that: Grades.to_code([7]), is_equal_to: "C"
  check that: Grades.to_code([8]), is_equal_to: "B"
  check that: Grades.to_code([9]), is_equal_to: "B"
  check that: Grades.to_code([10]), is_equal_to: "A"
  check that: Grades.to_code([20]), is_equal_to: "A"
  check that: Grades.to_code([20, 20]), is_equal_to: "AA"
  check that: Grades.to_code([20, 20, 10]), is_equal_to: "AAA"
  check that: Grades.to_code([0, 9, 10]), is_equal_to: "CBA"
  check that: Grades.to_code([11, 8, 5]), is_equal_to: "ABC"
  check that: Grades.to_code([11, 8, 5, 12, 9, 1]), is_equal_to: "ABCABC"
end
