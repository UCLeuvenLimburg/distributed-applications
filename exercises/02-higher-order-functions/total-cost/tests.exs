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

  check that: Store.total_cost( %{ a: 5 }, [ :a ] ), is_equal_to: 5
  check that: Store.total_cost( %{ a: 10 }, [ :a ] ), is_equal_to: 10
  check that: Store.total_cost( %{ a: 5 }, [ :a, :a ] ), is_equal_to: 10
  check that: Store.total_cost( %{ a: 5, b: 2 }, [ :a, :b ] ), is_equal_to: 7
  check that: Store.total_cost( %{ a: 5, b: 2, c: 7 }, [ :a ] ), is_equal_to: 5
  check that: Store.total_cost( %{ a: 5, b: 2, c: 7 }, [ :b ] ), is_equal_to: 2
  check that: Store.total_cost( %{ a: 5, b: 2, c: 7 }, [ :c ] ), is_equal_to: 7
  check that: Store.total_cost( %{ a: 8, b: 10, c: 5 }, [ :c ] ), is_equal_to: 5
  check that: Store.total_cost( %{ a: 8, b: 10, c: 5 }, [ :c, :a ] ), is_equal_to: 5 + 8
  check that: Store.total_cost( %{ a: 8, b: 10, c: 5 }, [ :c, :a, :b ] ), is_equal_to: 5 + 8 + 10
end
