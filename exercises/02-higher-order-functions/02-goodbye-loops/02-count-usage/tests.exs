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


  check that: Grades.passed_percentage([1]), is_equal_to: 0
  check that: Grades.passed_percentage([10]), is_equal_to: 100
  check that: Grades.passed_percentage([20]), is_equal_to: 100
  check that: Grades.passed_percentage([5]), is_equal_to: 0
  check that: Grades.passed_percentage([5, 10]), is_equal_to: 50
  check that: Grades.passed_percentage([10, 9]), is_equal_to: 50
  check that: Grades.passed_percentage([5, 10, 5, 10]), is_equal_to: 50
  check that: Grades.passed_percentage([5, 10, 5]), is_equal_to: 33
  check that: Grades.passed_percentage([5, 10, 15]), is_equal_to: 67
end
