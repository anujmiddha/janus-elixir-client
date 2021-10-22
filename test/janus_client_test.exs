defmodule JanusClientTest do
  use ExUnit.Case
  doctest JanusClient

  test "greets the world" do
    assert JanusClient.hello() == :world
  end
end
