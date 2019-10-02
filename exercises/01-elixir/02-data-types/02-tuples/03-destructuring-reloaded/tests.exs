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

  check that: Cards.higher?({:ace, :hearts}, {5, :hearts}, :hearts), is_equal_to: true
  check that: Cards.higher?({:jack, :hearts}, {:king, :hearts}, :hearts), is_equal_to: false
  check that: Cards.higher?({:ace, :hearts}, {5, :hearts}, :clubs), is_equal_to: true
  check that: Cards.higher?({2, :clubs}, {5, :hearts}, :clubs), is_equal_to: true
  check that: Cards.higher?({2, :clubs}, {5, :hearts}, :diamonds), is_equal_to: true
  check that: Cards.higher?({2, :clubs}, {5, :hearts}, :hearts), is_equal_to: false
  check that: Cards.higher?({8, :clubs}, {5, :diamonds}, :hearts), is_equal_to: true
  check that: Cards.higher?({8, :clubs}, {:queen, :diamonds}, :hearts), is_equal_to: true
  check that: Cards.higher?({8, :clubs}, {8, :clubs}, :hearts), is_equal_to: false
end
