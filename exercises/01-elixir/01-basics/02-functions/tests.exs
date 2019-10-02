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

  check(that: Temperature.kelvin_to_celsius(0), is_equal_to: -273.15)
  check(that: Temperature.kelvin_to_celsius(273.15), is_equal_to: 0)
  check(that: Temperature.kelvin_to_celsius(283.15), is_equal_to: 10)

  check(that: Temperature.celsius_to_kelvin(-273.15), is_equal_to: 0)
  check(that: Temperature.celsius_to_kelvin(0), is_equal_to: 273.15)
  check(that: Temperature.celsius_to_kelvin(10), is_equal_to: 283.15)
end
