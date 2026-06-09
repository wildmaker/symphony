defmodule SymphonyElixir.CodexSessionStreamTest do
  use SymphonyElixir.TestSupport

  alias SymphonyElixir.Codex.SessionStream

  test "blocks merges assistant deltas and folds command output separately" do
    events = [
      event("2026-06-09T03:55:29Z", "codex/event/agent_message_content_delta", %{"content" => "Hello "}),
      event("2026-06-09T03:55:30Z", "codex/event/agent_message_content_delta", %{"content" => "world"}),
      event("2026-06-09T03:55:31Z", "item/commandExecution/outputDelta", %{
        "outputDelta" => "mix test\n"
      }),
      event("2026-06-09T03:55:32Z", "item/commandExecution/outputDelta", %{
        "outputDelta" => "2 tests, 0 failures\n"
      }),
      event("2026-06-09T03:55:33Z", "codex/event/agent_message_content_delta", %{
        "content" => "Done."
      })
    ]

    assert [
             %{
               kind: :assistant,
               title: "Assistant",
               text: "Hello world",
               event_count: 2
             },
             %{
               kind: :tool,
               title: "Command output",
               text: "mix test\n2 tests, 0 failures\n",
               event_count: 2
             },
             %{
               kind: :assistant,
               title: "Assistant",
               text: "Done.",
               event_count: 1
             }
           ] = SessionStream.blocks(events)
  end

  test "blocks falls back to activity when no streamable events are present" do
    assert [
             %{
               kind: :activity,
               title: "Notification",
               text: "item completed: agent message"
             }
           ] =
             SessionStream.blocks([
               %{
                 at: "2026-06-09T03:55:29Z",
                 event: "notification",
                 message: "item completed: agent message",
                 raw: %{payload: %{"method" => "item/completed"}}
               }
             ])
  end

  defp event(at, method, params) do
    %{
      at: at,
      event: "notification",
      message: method,
      raw: %{
        payload: %{
          "method" => method,
          "params" => %{"msg" => params}
        }
      }
    }
  end
end
