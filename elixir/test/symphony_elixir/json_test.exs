defmodule SymphonyElixir.JSONTest do
  use SymphonyElixir.TestSupport

  alias SymphonyElixir.JSON

  test "sanitize replaces invalid UTF-8 bytes recursively" do
    invalid = "broken " <> <<0xE5>>

    assert JSON.sanitize(%{"title" => invalid, "nested" => [invalid]}) == %{
             "title" => "broken �",
             "nested" => ["broken �"]
           }
  end
end
