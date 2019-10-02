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

  check that: Util.increasing?([]), is_equal_to: true
  check that: Util.increasing?([1]), is_equal_to: true
  check that: Util.increasing?([1, 2]), is_equal_to: true
  check that: Util.increasing?([1, 1]), is_equal_to: true
  check that: Util.increasing?([1, 2, 3]), is_equal_to: true
  check that: Util.increasing?([1, 4, 6, 10]), is_equal_to: true
  check that: Util.increasing?([1, 4, 6, 10, 100, 1000]), is_equal_to: true

  check that: Util.increasing?([1, 0]), is_equal_to: false
  check that: Util.increasing?([5, 4, 3, 2, 1]), is_equal_to: false
  check that: Util.increasing?([1, 2, 3, 2, 3, 4]), is_equal_to: false
end
