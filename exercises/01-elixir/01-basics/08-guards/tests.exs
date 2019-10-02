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

  check that: Numbers.odd?(1), is_equal_to: true
  check that: Numbers.odd?(5), is_equal_to: true
  check that: Numbers.odd?(7), is_equal_to: true
  check that: Numbers.odd?(19), is_equal_to: true
  check that: Numbers.odd?(-19), is_equal_to: true
  check that: Numbers.odd?(0), is_equal_to: false
  check that: Numbers.odd?(2), is_equal_to: false
  check that: Numbers.odd?(4), is_equal_to: false
  check that: Numbers.odd?(80), is_equal_to: false
  check that: Numbers.odd?(-78), is_equal_to: false

  check that: Numbers.even?(0), is_equal_to: true
  check that: Numbers.even?(2), is_equal_to: true
  check that: Numbers.even?(8), is_equal_to: true
  check that: Numbers.even?(16), is_equal_to: true
  check that: Numbers.even?(-16), is_equal_to: true
  check that: Numbers.even?(1), is_equal_to: false
  check that: Numbers.even?(5), is_equal_to: false
  check that: Numbers.even?(-5), is_equal_to: false

  must_raise(FunctionClauseError) do
    Numbers.odd?("abc")
  end

  must_raise(FunctionClauseError) do
    Numbers.even?("abc")
  end
end
