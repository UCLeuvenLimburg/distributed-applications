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

  check that: Cards.same_suit?({ 2, :hearts }, { 2, :hearts }), is_equal_to: true
  check that: Cards.same_suit?({ 2, :hearts }, { 3, :hearts }), is_equal_to: true
  check that: Cards.same_suit?({ 2, :hearts }, { 2, :spades }), is_equal_to: false
  check that: Cards.same_suit?({ 2, :hearts }, { 3, :spades }), is_equal_to: false
end
