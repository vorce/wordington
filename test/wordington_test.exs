defmodule WordingtonTest do
  use ExUnit.Case
  doctest Wordington

  describe "candidates/3" do
    test "finds monument" do
      available = ["t", "u", "n", "m", "e", "m", "n", "o"]
      pattern = ["_", "_", "_", "u", "_", "_", "_", "_"]
      assert Wordington.candidates(pattern, available) == ["monument"]
    end

    test "finds brygga, brygge" do
      pattern = ["_", "_", "_", "_", "g", "_"]
      available_letters = ["e", "r", "g", "g", "y", "a", "b"]

      assert Wordington.candidates(pattern, available_letters) ==
               ["brygga", "brygge"]
    end

    test "finds many candidates" do
      pattern = ["_", "_", "_", "_"]
      available_letters = ["y", "g", "n", "a", "d"]
      assert Wordington.candidates(pattern, available_letters) == ["andy", "dygn", "dyna"]
    end
  end
end
