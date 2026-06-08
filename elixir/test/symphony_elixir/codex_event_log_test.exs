defmodule SymphonyElixir.CodexEventLogTest do
  use SymphonyElixir.TestSupport

  alias SymphonyElixir.Codex.EventLog

  test "append stores bounded humanized and redacted event entries" do
    now = DateTime.utc_now()

    first =
      EventLog.append(nil, %{
        event: :notification,
        payload: %{
          "method" => "codex/event/agent_message_content_delta",
          "params" => %{"msg" => %{"content" => "first LINEAR_API_KEY=lin_api_aaaaaaaaaaaaaaaaaaaaaaaa"}}
        },
        timestamp: now
      })

    events =
      EventLog.append(
        first,
        %{
          "event" => "notification",
          "payload" => %{
            "method" => "codex/event/agent_message_content_delta",
            "params" => %{"msg" => %{"content" => "second"}}
          },
          "timestamp" => now
        },
        1
      )

    assert [
             %{
               at: ^now,
               event: "notification",
               message: "agent message content streaming: second",
               raw: %{event: "notification"}
             }
           ] = events

    redacted_first = List.first(first)
    assert redacted_first.message =~ "LINEAR_API_KEY=[REDACTED]"
    refute inspect(redacted_first.raw) =~ "lin_api_aaaaaaaaaaaaaaaaaaaaaaaa"
  end

  test "append ignores malformed updates without inventing state" do
    assert [%{event: :kept}] = EventLog.append([%{event: :kept}], :bad, 1)
    assert [] = EventLog.append(:bad, :bad, 1)
  end

  test "redact handles sensitive keys, token patterns, lists, structs, and long strings" do
    now = DateTime.utc_now()
    long_value = String.duplicate("x", 20_005)

    redacted =
      EventLog.redact(%{
        token: "plain-secret",
        nested: [
          %{"Authorization" => "Bearer abcdefghijklmnopqrstuvwxyz"},
          "OPENAI_API_KEY=sk-abcdefghijklmnopqrstuvwxyz123456"
        ],
        timestamp: now,
        long: long_value,
        count: 1
      })

    assert redacted.token == "[REDACTED]"

    assert redacted.nested == [
             %{"Authorization" => "[REDACTED]"},
             "OPENAI_API_KEY=[REDACTED]"
           ]

    assert redacted.timestamp == now
    assert redacted.long =~ "[truncated]"
    assert redacted.count == 1
  end
end
