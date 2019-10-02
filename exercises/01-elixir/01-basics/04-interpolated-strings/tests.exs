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

  check that: Date.format(1, 1, 2000), is_equal_to: "1-1-2000"
  check that: Date.format(2, 1, 2000), is_equal_to: "2-1-2000"
  check that: Date.format(1, 2, 2000), is_equal_to: "1-2-2000"
  check that: Date.format(1, 1, 2002), is_equal_to: "1-1-2002"
end
