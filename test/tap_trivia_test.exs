defmodule TapTriviaTest do
  use ExUnit.Case
  doctest TapTrivia

  test "greets the world" do
    assert TapTrivia.hello() == :world
  end
end
