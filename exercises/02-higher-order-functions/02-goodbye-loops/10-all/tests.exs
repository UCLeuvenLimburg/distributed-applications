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


  check that: Grades.all_passed?([]), is_equal_to: true
  check that: Grades.all_passed?([0]), is_equal_to: false
  check that: Grades.all_passed?([9]), is_equal_to: false
  check that: Grades.all_passed?([10]), is_equal_to: true
  check that: Grades.all_passed?([10, 11]), is_equal_to: true
  check that: Grades.all_passed?([10, 11, 18]), is_equal_to: true
  check that: Grades.all_passed?([20]), is_equal_to: true
  check that: Grades.all_passed?([:na]), is_equal_to: true
  check that: Grades.all_passed?([10, 11, 5, 12]), is_equal_to: false
  check that: Grades.all_passed?([10, 11, 12, 8]), is_equal_to: false
  check that: Grades.all_passed?([10, 11, 12, :na, 8]), is_equal_to: false
  check that: Grades.all_passed?([10, 11, 12, :na]), is_equal_to: true
end
