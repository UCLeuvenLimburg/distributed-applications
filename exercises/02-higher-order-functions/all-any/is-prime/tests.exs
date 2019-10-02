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

  check that: Math.prime?(0), is_equal_to: false
  check that: Math.prime?(1), is_equal_to: false
  check that: Math.prime?(2), is_equal_to: true
  check that: Math.prime?(3), is_equal_to: true
  check that: Math.prime?(4), is_equal_to: false
  check that: Math.prime?(5), is_equal_to: true
  check that: Math.prime?(6), is_equal_to: false
  check that: Math.prime?(7), is_equal_to: true
  check that: Math.prime?(8), is_equal_to: false
  check that: Math.prime?(9), is_equal_to: false
  check that: Math.prime?(10), is_equal_to: false
  check that: Math.prime?(11), is_equal_to: true
  check that: Math.prime?(97), is_equal_to: true
  check that: Math.prime?(100), is_equal_to: false
  check that: Math.prime?(541), is_equal_to: true
end
