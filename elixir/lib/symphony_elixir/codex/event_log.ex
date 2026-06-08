defmodule SymphonyElixir.Codex.EventLog do
  @moduledoc """
  Builds bounded, redacted Codex event timelines for observability surfaces.
  """

  alias SymphonyElixir.StatusDashboard

  @default_limit 500
  @max_string_length 20_000
  @sensitive_keys MapSet.new([
                    "apikey",
                    "authorization",
                    "authtoken",
                    "bearertoken",
                    "clientsecret",
                    "githubtoken",
                    "idtoken",
                    "linearapikey",
                    "openaiapikey",
                    "password",
                    "refreshtoken",
                    "secret",
                    "secretkey",
                    "sessiontoken",
                    "token"
                  ])

  @spec append([map()] | nil, map()) :: [map()]
  def append(events, update), do: append(events, update, @default_limit)

  @spec append([map()] | nil, map(), pos_integer()) :: [map()]
  def append(events, update, limit) when is_map(update) and is_integer(limit) and limit > 0 do
    events =
      case events do
        events when is_list(events) -> events
        _ -> []
      end

    events
    |> Kernel.++([event_entry(update)])
    |> Enum.take(-limit)
  end

  def append(events, _update, _limit) when is_list(events), do: events
  def append(_events, _update, _limit), do: []

  @spec redact(term()) :: term()
  def redact(%{__struct__: _} = struct), do: struct

  def redact(%{} = map) do
    Map.new(map, fn {key, value} ->
      if sensitive_key?(key) do
        {key, "[REDACTED]"}
      else
        {key, redact(value)}
      end
    end)
  end

  def redact(value) when is_list(value), do: Enum.map(value, &redact/1)

  def redact(value) when is_binary(value) do
    value
    |> redact_secret_patterns()
    |> truncate_string()
  end

  def redact(value), do: value

  defp event_entry(update) do
    summary = summary_for_update(update)
    redacted_summary = redact(summary)

    %{
      at: update[:timestamp] || Map.get(update, "timestamp"),
      event: update[:event] || Map.get(update, "event"),
      message: StatusDashboard.humanize_codex_message(redacted_summary),
      raw: redact(raw_for_update(update))
    }
  end

  defp summary_for_update(update) do
    %{
      event: update[:event] || Map.get(update, "event"),
      message: update[:payload] || Map.get(update, "payload") || update[:raw] || Map.get(update, "raw"),
      timestamp: update[:timestamp] || Map.get(update, "timestamp")
    }
  end

  defp raw_for_update(update) do
    [
      :event,
      :timestamp,
      :session_id,
      :codex_app_server_pid,
      :payload,
      :raw,
      :details,
      :usage,
      :rate_limits
    ]
    |> Enum.reduce(%{}, fn key, acc ->
      string_key = Atom.to_string(key)

      cond do
        Map.has_key?(update, key) -> Map.put(acc, key, Map.get(update, key))
        Map.has_key?(update, string_key) -> Map.put(acc, key, Map.get(update, string_key))
        true -> acc
      end
    end)
  end

  defp sensitive_key?(key) do
    key
    |> to_string()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]/, "")
    |> then(&MapSet.member?(@sensitive_keys, &1))
  end

  defp redact_secret_patterns(value) do
    value
    |> String.replace(~r/(?i)\bBearer\s+[A-Za-z0-9._~+\/=-]{12,}/, "Bearer [REDACTED]")
    |> String.replace(
      ~r/(?i)((?:api[_-]?key|access[_-]?token|refresh[_-]?token|id[_-]?token|auth[_-]?token|password|secret)\s*[:=]\s*["']?)[^"'\s,;}]+/,
      "\\1[REDACTED]"
    )
    |> String.replace(~r/\bsk-proj-[A-Za-z0-9_-]{20,}\b/, "sk-proj-[REDACTED]")
    |> String.replace(~r/\bsk-[A-Za-z0-9_-]{20,}\b/, "sk-[REDACTED]")
    |> String.replace(~r/\blin_api_[A-Za-z0-9_-]{20,}\b/, "lin_api_[REDACTED]")
    |> String.replace(~r/\bgithub_pat_[A-Za-z0-9_]{20,}\b/, "github_pat_[REDACTED]")
    |> String.replace(~r/\bgh[opsru]_[A-Za-z0-9_]{20,}\b/, "gh[REDACTED]")
  end

  defp truncate_string(value) do
    if String.length(value) > @max_string_length do
      String.slice(value, 0, @max_string_length) <> "\n[truncated]"
    else
      value
    end
  end
end
