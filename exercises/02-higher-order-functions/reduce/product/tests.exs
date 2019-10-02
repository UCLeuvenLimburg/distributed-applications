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

  check that: Math.product([]), is_equal_to: 1
  check that: Math.product([5]), is_equal_to: 5
  check that: Math.product([5, 2]), is_equal_to: 5 * 2
  check that: Math.product([5, 2, 3]), is_equal_to: 5 * 2 * 3
  check that: Math.product([5, 2, 3, 8]), is_equal_to: 5 * 2 * 3 * 8
end
