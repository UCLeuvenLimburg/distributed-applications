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


  check that: Grades.any_tolerable?([]), is_equal_to: false
  check that: Grades.any_tolerable?([1]), is_equal_to: false
  check that: Grades.any_tolerable?([7]), is_equal_to: false
  check that: Grades.any_tolerable?([10]), is_equal_to: false
  check that: Grades.any_tolerable?([8]), is_equal_to: true
  check that: Grades.any_tolerable?([9]), is_equal_to: true
  check that: Grades.any_tolerable?([1, 10]), is_equal_to: false
  check that: Grades.any_tolerable?([1, 2, 3, 4, 5]), is_equal_to: false
  check that: Grades.any_tolerable?([1, 2, 3, 4, 5, 8]), is_equal_to: true
  check that: Grades.any_tolerable?([:na, 5, 10]), is_equal_to: false
  check that: Grades.any_tolerable?([:na, 5, 10, 9]), is_equal_to: true
  check that: Grades.any_tolerable?([:na, 5, 10, 9, :na]), is_equal_to: true
end
