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

  check that: Shop.discount(:standard).(10), is_equal_to: 10
  check that: Shop.discount(:standard).(50), is_equal_to: 50
  check that: Shop.discount(:bronze).(50), is_equal_to: 50 * 0.95
  check that: Shop.discount(:bronze).(100), is_equal_to: 100 * 0.95
  check that: Shop.discount(:silver).(100), is_equal_to: 100 * 0.9
  check that: Shop.discount(:silver).(400), is_equal_to: 400 * 0.9
  check that: Shop.discount(:gold).(400), is_equal_to: 400 * 0.8
  check that: Shop.discount(:gold).(1000), is_equal_to: 1000 * 0.8
end
