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


  check that: Cards.higher?(7, 5), is_equal_to: true
  check that: Cards.higher?(10, 2), is_equal_to: true
  check that: Cards.higher?(:king, 10), is_equal_to: true
  check that: Cards.higher?(:ace, :king), is_equal_to: true
  check that: Cards.higher?(:king, :queen), is_equal_to: true
  check that: Cards.higher?(:queen, :jack), is_equal_to: true
  check that: Cards.higher?(:king, :jack), is_equal_to: true
  check that: Cards.higher?(:jack, 10), is_equal_to: true
  check that: Cards.higher?(:ace, 2), is_equal_to: true
  check that: Cards.higher?(3, 2), is_equal_to: true

  check that: Cards.higher?(2, 2), is_equal_to: false
  check that: Cards.higher?(2, :ace), is_equal_to: false
  check that: Cards.higher?(4, :ace), is_equal_to: false
  check that: Cards.higher?(:ace, :ace), is_equal_to: false
  check that: Cards.higher?(:king, :ace), is_equal_to: false
  check that: Cards.higher?(:king, :king), is_equal_to: false
  check that: Cards.higher?(:queen, :ace), is_equal_to: false
  check that: Cards.higher?(:jack, :ace), is_equal_to: false
  check that: Cards.higher?(10, :ace), is_equal_to: false
  check that: Cards.higher?(8, 10), is_equal_to: false
end
