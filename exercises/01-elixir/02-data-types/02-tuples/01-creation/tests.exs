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


  check that: Math.quotrem(5, 1), is_equal_to: {5, 0}
  check that: Math.quotrem(5, 2), is_equal_to: {2, 1}
  check that: Math.quotrem(6, 3), is_equal_to: {2, 0}
  check that: Math.quotrem(6, 4), is_equal_to: {1, 2}
end
