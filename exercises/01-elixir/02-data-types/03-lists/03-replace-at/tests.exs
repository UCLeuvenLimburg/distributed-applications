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

  check(that: Util.replace_at([1], 0, 0), is_equal_to: [0])
  check(that: Util.replace_at([1, 2], 0, 0), is_equal_to: [0, 2])
  check(that: Util.replace_at([1, 2], 0, 5), is_equal_to: [5, 2])
  check(that: Util.replace_at([1, 2], 1, 0), is_equal_to: [1, 0])
  check(that: Util.replace_at([1, 2], 1, 5), is_equal_to: [1, 5])
  check(that: Util.replace_at([1, 2, 3, 4, 5, 6], 3, 0), is_equal_to: [1, 2, 3, 0, 5, 6])
end
