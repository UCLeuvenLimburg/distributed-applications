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

  check that: Util.size([]), is_equal_to: 0
  check that: Util.size([:a]), is_equal_to: 1
  check that: Util.size([:a, :a]), is_equal_to: 2
  check that: Util.size([:a, :b, :c]), is_equal_to: 3
  check that: Util.size([0, 0, 0, 0, 0]), is_equal_to: 5
end
