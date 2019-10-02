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

  check that: Functions.fixedpoint(fn x -> div(x, 2) end, 16), is_equal_to: 0
  check that: Functions.fixedpoint(fn x -> div(x, 2) + 1 end, 1), is_equal_to: 1
  check that: Functions.fixedpoint(fn x -> div(x, 2) + 1 end, 50), is_equal_to: 2
  check that: Functions.fixedpoint(fn x -> div(x, 2) + 2 end, 2), is_equal_to: 3
  check that: Functions.fixedpoint(fn x -> div(x, 2) + 2 end, 50), is_equal_to: 4
end
