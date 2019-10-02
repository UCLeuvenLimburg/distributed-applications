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

  check that: Util.range(0, 0), is_equal_to: [0]
  check that: Util.range(0, 1), is_equal_to: [0, 1]
  check that: Util.range(0, 5), is_equal_to: [0, 1, 2, 3, 4, 5]
  check that: Util.range(3, 5), is_equal_to: [3, 4, 5]
  check that: Util.range(5, 5), is_equal_to: [5]
  check that: Util.range(6, 5), is_equal_to: []
end
