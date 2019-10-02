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


  check that: Bank.largest_expense_index([100, 0]), is_equal_to: 0
  check that: Bank.largest_expense_index([100, 110, 0]), is_equal_to: 1
  check that: Bank.largest_expense_index([100, 90, 70]), is_equal_to: 1
  check that: Bank.largest_expense_index([100, 90, 70, 0]), is_equal_to: 2
  check that: Bank.largest_expense_index([0, 100, 50, 200, 190, 150]), is_equal_to: 1
  check that: Bank.largest_expense_index([0, 100, 50, 200, 190, 150, 0]), is_equal_to: 5
end
