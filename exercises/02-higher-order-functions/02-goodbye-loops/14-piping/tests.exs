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
  @s6 { "r0000005", "Donnie", 19 }

  check that: Grades.best_students([ @s1 ]), is_equal_to: [ "Stanley" ]
  check that: Grades.best_students([ @s1, @s2 ]), is_equal_to: [ "Stanley", "Sydney" ]
  check that: Grades.best_students([ @s1, @s2, @s3 ]), is_equal_to: [ "Stanley", "Claudia", "Sydney" ]
  check that: Grades.best_students([ @s2, @s3 ]), is_equal_to: [ "Claudia", "Sydney" ]
  check that: Grades.best_students([ @s1, @s2, @s3, @s4, @s5, @s6 ]), is_equal_to: [ "Stanley", "Donnie", "Rose" ]
end
