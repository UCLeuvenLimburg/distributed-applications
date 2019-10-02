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

  check that: Util.maximum([1]), is_equal_to: 1
  check that: Util.maximum([1, 4]), is_equal_to: 4
  check that: Util.maximum([4, 1]), is_equal_to: 4
  check that: Util.maximum([5, 1]), is_equal_to: 5
  check that: Util.maximum([4, 7, 0]), is_equal_to: 7
  check that: Util.maximum([4, 7, 9]), is_equal_to: 9
  check that: Util.maximum([4, 7, 9, 40, 2, 5]), is_equal_to: 40
end
