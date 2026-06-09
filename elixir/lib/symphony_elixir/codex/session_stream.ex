defmodule SymphonyElixir.Codex.SessionStream do
  @moduledoc """
  Converts bounded Codex event entries into readable session stream blocks.
  """

  @assistant_methods MapSet.new([
                       "codex/event/agent_message_delta",
                       "codex/event/agent_message_content_delta",
                       "item/agentMessage/delta"
                     ])

  @reasoning_methods MapSet.new([
                       "codex/event/agent_reasoning",
                       "codex/event/agent_reasoning_delta",
                       "codex/event/reasoning_content_delta",
                       "codex/event/agent_reasoning_section_break",
                       "item/reasoning/summaryTextDelta",
                       "item/reasoning/summaryPartAdded",
                       "item/reasoning/textDelta"
                     ])

  @tool_method_fragments [
    "commandExecution",
    "exec_command",
    "fileChange",
    "mcp_tool_call",
    "tool_call",
    "item/tool/"
  ]

  @max_block_text 40_000

  @type block_kind :: :assistant | :tool | :reasoning | :activity

  @type block :: %{
          required(:kind) => block_kind(),
          required(:title) => String.t(),
          required(:text) => String.t(),
          required(:at) => term(),
          required(:event_count) => non_neg_integer(),
          required(:raw_events) => [map()]
        }

  @spec blocks([map()] | nil) :: [block()]
  def blocks(events) when is_list(events) do
    blocks =
      events
      |> Enum.flat_map(&stream_event/1)
      |> Enum.reduce([], &append_block/2)
      |> Enum.reverse()

    if blocks == [] do
      events
      |> Enum.flat_map(&activity_event/1)
      |> Enum.reduce([], &append_block/2)
      |> Enum.reverse()
    else
      blocks
    end
  end

  def blocks(_events), do: []

  defp stream_event(event) when is_map(event) do
    payload = payload_for_event(event)
    method = method_for_payload(payload)

    cond do
      MapSet.member?(@assistant_methods, method) ->
        text_event(event, payload, :assistant, "Assistant")

      MapSet.member?(@reasoning_methods, method) ->
        text_event(event, payload, :reasoning, "Reasoning")

      tool_method?(method) ->
        tool_event(event, payload, method)

      important_activity?(event) ->
        activity_event(event)

      true ->
        []
    end
  end

  defp stream_event(_event), do: []

  defp text_event(event, payload, kind, title) do
    case extract_text(payload) do
      nil ->
        activity_event(event)

      text ->
        [new_block(event, kind, title, text)]
    end
  end

  defp tool_event(event, payload, method) do
    text =
      extract_text(payload) ||
        extract_command(payload) ||
        Map.get(event, :message) ||
        Map.get(event, "message")

    case text do
      value when is_binary(value) and value != "" ->
        [new_block(event, :tool, tool_title(payload, method), value)]

      _ ->
        activity_event(event)
    end
  end

  defp activity_event(event) when is_map(event) do
    case Map.get(event, :message) || Map.get(event, "message") do
      value when is_binary(value) and value != "" ->
        [new_block(event, :activity, activity_title(event), value)]

      _ ->
        []
    end
  end

  defp activity_event(_event), do: []

  defp append_block(block, []) do
    [block]
  end

  defp append_block(block, [last | rest] = blocks) do
    if mergeable?(last, block) do
      [merge_blocks(last, block) | rest]
    else
      [block | blocks]
    end
  end

  defp mergeable?(%{kind: :assistant}, %{kind: :assistant}), do: true
  defp mergeable?(%{kind: :reasoning}, %{kind: :reasoning}), do: true
  defp mergeable?(%{kind: :tool, title: title}, %{kind: :tool, title: title}), do: true
  defp mergeable?(%{kind: :activity, title: title}, %{kind: :activity, title: title}), do: true
  defp mergeable?(_last, _block), do: false

  defp merge_blocks(last, block) do
    %{
      last
      | text: append_text(last.text, block.text),
        event_count: last.event_count + block.event_count,
        raw_events: last.raw_events ++ block.raw_events
    }
  end

  defp append_text("", next), do: truncate_text(next)

  defp append_text(existing, next) do
    separator = if String.ends_with?(existing, ["\n", " "]) or String.starts_with?(next, ["\n", " "]), do: "", else: "\n"
    truncate_text(existing <> separator <> next)
  end

  defp truncate_text(value) when byte_size(value) > @max_block_text do
    value
    |> String.slice(0, @max_block_text)
    |> Kernel.<>("\n[truncated]")
  end

  defp truncate_text(value), do: value

  defp new_block(event, kind, title, text) do
    %{
      kind: kind,
      title: title,
      text: truncate_text(text),
      at: Map.get(event, :at) || Map.get(event, "at"),
      event_count: 1,
      raw_events: [raw_event(event)]
    }
  end

  defp payload_for_event(event) do
    raw = raw_event(event)

    raw
    |> map_value(["payload", :payload])
    |> decode_payload()
    |> unwrap_payload()
  end

  defp raw_event(event), do: Map.get(event, :raw) || Map.get(event, "raw") || %{}

  defp decode_payload(nil), do: nil
  defp decode_payload(%{} = payload), do: payload

  defp decode_payload(payload) when is_binary(payload) do
    case Jason.decode(payload) do
      {:ok, decoded} -> decoded
      {:error, _reason} -> payload
    end
  end

  defp decode_payload(payload), do: payload

  defp unwrap_payload(%{} = payload) do
    cond do
      is_binary(method_for_payload(payload)) ->
        payload

      is_map(map_value(payload, ["payload", :payload])) ->
        unwrap_payload(map_value(payload, ["payload", :payload]))

      true ->
        payload
    end
  end

  defp unwrap_payload(payload), do: payload

  defp method_for_payload(%{} = payload), do: map_value(payload, ["method", :method])
  defp method_for_payload(_payload), do: nil

  defp extract_text(payload) do
    payload
    |> first_path(text_paths())
    |> normalize_text()
  end

  defp normalize_text(value) when is_binary(value) do
    if String.trim(value) == "", do: nil, else: value
  end

  defp normalize_text(_value), do: nil

  defp extract_command(payload) do
    payload
    |> first_path(command_paths())
    |> normalize_command()
  end

  defp normalize_command(value) when is_binary(value), do: value

  defp normalize_command(values) when is_list(values) do
    if Enum.all?(values, &is_binary/1), do: Enum.join(values, " "), else: nil
  end

  defp normalize_command(_value), do: nil

  defp tool_title(payload, method) do
    cond do
      command_method?(method) ->
        case extract_command(payload) do
          nil -> "Command output"
          command -> "$ #{command}"
        end

      String.contains?(method || "", "fileChange") ->
        "File change"

      true ->
        "Tool output"
    end
  end

  defp activity_title(event) do
    event_name = Map.get(event, :event) || Map.get(event, "event") || "Activity"

    event_name
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp important_activity?(event) do
    event_name = event |> Map.get(:event) || Map.get(event, "event")
    event_name = to_string(event_name)

    event_name in [
      "session_started",
      "turn_input_required",
      "approval_required",
      "approval_auto_approved",
      "tool_input_auto_answered",
      "turn_failed",
      "turn_cancelled",
      "turn_ended_with_error",
      "startup_failed",
      "malformed"
    ]
  end

  defp command_method?(method) when is_binary(method),
    do: String.contains?(method, "commandExecution") or String.contains?(method, "exec_command")

  defp command_method?(_method), do: false

  defp tool_method?(method) when is_binary(method) do
    Enum.any?(@tool_method_fragments, &String.contains?(method, &1))
  end

  defp tool_method?(_method), do: false

  defp first_path(payload, paths) do
    Enum.find_value(paths, fn path -> map_path(payload, path) end)
  end

  defp map_path(data, [key | rest]) when is_map(data) do
    case fetch_map_key(data, key) do
      {:ok, value} when rest == [] -> value
      {:ok, value} -> map_path(value, rest)
      :error -> nil
    end
  end

  defp map_path(_data, _path), do: nil

  defp map_value(data, keys) when is_map(data) and is_list(keys) do
    Enum.find_value(keys, fn key ->
      case fetch_map_key(data, key) do
        {:ok, value} -> value
        :error -> nil
      end
    end)
  end

  defp map_value(_data, _keys), do: nil

  defp fetch_map_key(map, key) when is_map(map) do
    case Map.fetch(map, key) do
      {:ok, value} ->
        {:ok, value}

      :error ->
        key
        |> alternate_key()
        |> then(&Map.fetch(map, &1))
    end
  end

  defp alternate_key(key) when is_binary(key) do
    String.to_existing_atom(key)
  rescue
    ArgumentError -> key
  end

  defp alternate_key(key) when is_atom(key), do: Atom.to_string(key)
  defp alternate_key(key), do: key

  defp text_paths do
    [
      ["params", "msg", "content"],
      [:params, :msg, :content],
      ["params", "msg", "delta"],
      [:params, :msg, :delta],
      ["params", "msg", "payload", "content"],
      [:params, :msg, :payload, :content],
      ["params", "msg", "payload", "delta"],
      [:params, :msg, :payload, :delta],
      ["params", "content"],
      [:params, :content],
      ["params", "delta"],
      [:params, :delta],
      ["params", "outputDelta"],
      [:params, :outputDelta],
      ["params", "msg", "outputDelta"],
      [:params, :msg, :outputDelta],
      ["params", "msg", "payload", "outputDelta"],
      [:params, :msg, :payload, :outputDelta],
      ["params", "text"],
      [:params, :text],
      ["params", "textDelta"],
      [:params, :textDelta],
      ["params", "summaryText"],
      [:params, :summaryText],
      ["params", "msg", "text"],
      [:params, :msg, :text],
      ["params", "msg", "textDelta"],
      [:params, :msg, :textDelta],
      ["params", "msg", "summaryText"],
      [:params, :msg, :summaryText]
    ]
  end

  defp command_paths do
    [
      ["params", "parsedCmd"],
      [:params, :parsedCmd],
      ["params", "command"],
      [:params, :command],
      ["params", "cmd"],
      [:params, :cmd],
      ["params", "argv"],
      [:params, :argv],
      ["params", "args"],
      [:params, :args],
      ["params", "msg", "command"],
      [:params, :msg, :command]
    ]
  end
end
