defmodule SampleProjectTest do
  use ExUnit.Case
  doctest SampleProject

  test "greets the world" do
    assert SampleProject.hello() == :world
  end
end
