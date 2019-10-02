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
  import Integer


  check that: Math.factorial(1), is_equal_to: 1
  check that: Math.factorial(2), is_equal_to: 2
  check that: Math.factorial(3), is_equal_to: 6
  check that: Math.factorial(4), is_equal_to: 24
  check that: Math.factorial(5), is_equal_to: 120
  check that: Math.factorial(6), is_equal_to: 720
end
