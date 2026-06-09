defmodule SymphonyElixir.CodexSessionStreamTest do
  use SymphonyElixir.TestSupport

  alias SymphonyElixir.Codex.SessionStream

  test "blocks merges assistant deltas and folds command output separately" do
    events = [
      event("2026-06-09T03:55:29Z", "codex/event/agent_message_content_delta", %{
        "content" => "Hello ",
        "itemId" => "msg_1"
      }),
      event("2026-06-09T03:55:30Z", "codex/event/agent_message_content_delta", %{
        "content" => "world",
        "itemId" => "msg_1"
      }),
      event("2026-06-09T03:55:31Z", "item/commandExecution/outputDelta", %{
        "outputDelta" => "mix test\n",
        "itemId" => "call_1"
      }),
      event("2026-06-09T03:55:32Z", "item/commandExecution/outputDelta", %{
        "outputDelta" => "2 tests, 0 failures\n",
        "itemId" => "call_1"
      }),
      event("2026-06-09T03:55:33Z", "codex/event/agent_message_content_delta", %{
        "content" => "Done.",
        "itemId" => "msg_2"
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

  test "blocks appends stream deltas exactly without injecting line breaks" do
    events = [
      event("2026-06-09T03:55:29Z", "item/agentMessage/delta", %{
        "delta" => "I",
        "itemId" => "msg_split"
      }),
      event("2026-06-09T03:55:29Z", "item/agentMessage/delta", %{
        "delta" => "'m rer",
        "itemId" => "msg_split"
      }),
      event("2026-06-09T03:55:29Z", "item/agentMessage/delta", %{
        "delta" => "unning",
        "itemId" => "msg_split"
      })
    ]

    assert [%{kind: :assistant, text: "I'm rerunning", event_count: 3}] =
             SessionStream.blocks(events)
  end

  test "blocks prefers completed assistant text over streamed deltas for the same item" do
    events = [
      event("2026-06-09T03:55:29Z", "item/agentMessage/delta", %{
        "delta" => "target branch",
        "itemId" => "msg_completed"
      }),
      event("2026-06-09T03:55:29Z", "item/agentMessage/delta", %{
        "delta" => "'s new coverage",
        "itemId" => "msg_completed"
      }),
      completed_event("2026-06-09T03:55:30Z", %{
        "id" => "msg_completed",
        "type" => "agentMessage",
        "text" => "target branch's new coverage"
      })
    ]

    assert [
             %{
               kind: :assistant,
               text: "target branch's new coverage",
               event_count: 3,
               completed?: true
             }
           ] = SessionStream.blocks(events)
  end

  test "blocks keeps command text separate from command output" do
    events = [
      item_event("2026-06-09T03:55:29Z", "item/started", %{
        "id" => "call_git_status",
        "type" => "commandExecution",
        "command" => "git status --short"
      }),
      item_event("2026-06-09T03:55:30Z", "item/completed", %{
        "id" => "call_git_status",
        "type" => "commandExecution",
        "command" => "git status --short",
        "aggregatedOutput" => nil
      })
    ]

    assert [
             %{
               kind: :tool,
               title: "$ git status --short",
               command: "git status --short",
               text: "",
               event_count: 2,
               completed?: true
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

  defp completed_event(at, item) do
    item_event(at, "item/completed", item)
  end

  defp item_event(at, method, item) do
    %{
      at: at,
      event: "notification",
      message: method,
      raw: %{
        payload: %{
          "method" => method,
          "params" => %{"item" => item}
        }
      }
    }
  end
end
