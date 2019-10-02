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

  check that: Numbers.abs(0), is_equal_to: 0
  check that: Numbers.abs(1), is_equal_to: 1
  check that: Numbers.abs(-1), is_equal_to: 1
  check that: Numbers.abs(2), is_equal_to: 2
  check that: Numbers.abs(-2), is_equal_to: 2
end
