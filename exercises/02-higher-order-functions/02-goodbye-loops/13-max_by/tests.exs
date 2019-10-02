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

  @s1 { "r0000000", "Stanley", 20 }
  @s2 { "r0000001", "Sydney", 2 }
  @s3 { "r0000002", "Claudia", 10 }
  @s4 { "r0000003", "Rose", 17 }
  @s5 { "r0000004", "Jimmy", 8 }
  @s6 { "r0000005", "Phil", 16 }

  check that: Grades.best_student([ @s1 ]), is_equal_to: "Stanley"
  check that: Grades.best_student([ @s1, @s2 ]), is_equal_to: "Stanley"
  check that: Grades.best_student([ @s1, @s2, @s3 ]), is_equal_to: "Stanley"
  check that: Grades.best_student([ @s2, @s3 ]), is_equal_to: "Claudia"
  check that: Grades.best_student([ @s2, @s3, @s4 ]), is_equal_to: "Rose"
  check that: Grades.best_student([ @s2, @s3, @s4, @s5 ]), is_equal_to: "Rose"
  check that: Grades.best_student([ @s2, @s3, @s4, @s5, @s6 ]), is_equal_to: "Rose"
  check that: Grades.best_student([ @s2, @s3, @s5, @s6 ]), is_equal_to: "Phil"
end
