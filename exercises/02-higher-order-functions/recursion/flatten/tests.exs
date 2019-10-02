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

  check that: Exercise.flatten([]), is_equal_to: []
  check that: Exercise.flatten([1]), is_equal_to: [1]
  check that: Exercise.flatten([1, 2]), is_equal_to: [1, 2]
  check that: Exercise.flatten([[1]]), is_equal_to: [1]
  check that: Exercise.flatten([[1, 2]]), is_equal_to: [1, 2]
  check that: Exercise.flatten([[[1, 2]]]), is_equal_to: [1, 2]
  check that: Exercise.flatten([[1],[2],[3]]), is_equal_to: [1, 2, 3]
  check that: Exercise.flatten([[:a, :b], [[:c]], [:d, [:e]]]), is_equal_to: [:a, :b, :c, :d, :e]
end
