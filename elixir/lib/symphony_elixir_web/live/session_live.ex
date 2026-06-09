defmodule SymphonyElixirWeb.SessionLive do
  @moduledoc """
  Live Codex session detail page for an issue.
  """

  use Phoenix.LiveView, layout: {SymphonyElixirWeb.Layouts, :app}

  alias SymphonyElixir.Codex.SessionStream
  alias SymphonyElixirWeb.{Endpoint, ObservabilityPubSub, Presenter}

  @impl true
  def mount(%{"issue_identifier" => issue_identifier}, _session, socket) do
    socket =
      socket
      |> assign(:issue_identifier, issue_identifier)
      |> assign_payload()

    if connected?(socket) do
      :ok = ObservabilityPubSub.subscribe()
    end

    {:ok, socket}
  end

  @impl true
  def handle_info(:observability_updated, socket) do
    {:noreply, assign_payload(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class="dashboard-shell session-detail-shell">
      <header class="hero-card session-hero">
        <div class="hero-grid">
          <div>
            <p class="eyebrow">Codex Session</p>
            <h1 class="hero-title"><%= @issue_identifier %></h1>
            <p class="hero-copy">Live Codex output, runtime metadata, and redacted raw events for this issue.</p>
          </div>

          <div class="status-stack">
            <a class="subtle-link" href="/">Dashboard</a>
            <span class="status-badge status-badge-live">
              <span class="status-badge-dot"></span>
              Live
            </span>
            <span class="status-badge status-badge-offline">
              <span class="status-badge-dot"></span>
              Offline
            </span>
          </div>
        </div>
      </header>

      <%= if @error do %>
        <section class="error-card">
          <h2 class="error-title">Session unavailable</h2>
          <p class="error-copy"><%= @error %></p>
        </section>
      <% else %>
        <section class="metric-grid session-metadata-grid">
          <article class="metric-card">
            <p class="metric-label">Status</p>
            <p class="metric-value session-metric-value"><%= @payload.status %></p>
            <p class="metric-detail">Current Symphony state for this issue.</p>
          </article>

          <article class="metric-card">
            <p class="metric-label">Session ID</p>
            <p class="metric-value session-metric-value mono"><%= session_id(@payload) || "n/a" %></p>
            <p class="metric-detail">Latest Codex thread-turn identifier.</p>
          </article>

          <article class="metric-card">
            <p class="metric-label">Tokens</p>
            <p class="metric-value session-metric-value numeric"><%= format_tokens(@payload) %></p>
            <p class="metric-detail">Input / output / total for the active session.</p>
          </article>
        </section>

        <section class="section-card">
          <div class="section-header">
            <div>
              <h2 class="section-title">Workspace</h2>
              <p class="section-copy">Runtime location for the current worker.</p>
            </div>
          </div>

          <dl class="metadata-list">
            <div>
              <dt>Issue</dt>
              <dd>
                <%= if @payload.running && @payload.running[:state] do %>
                  <span class={state_badge_class(@payload.running.state)}><%= @payload.running.state %></span>
                <% else %>
                  <span class={state_badge_class(@payload.status)}><%= @payload.status %></span>
                <% end %>
              </dd>
            </div>
            <div>
              <dt>Workspace path</dt>
              <dd class="mono"><%= @payload.workspace.path || "n/a" %></dd>
            </div>
            <div>
              <dt>Worker host</dt>
              <dd class="mono"><%= @payload.workspace.host || "local" %></dd>
            </div>
            <div>
              <dt>JSON API</dt>
              <dd><a class="issue-link" href={"/api/v1/#{@issue_identifier}/events"}>Event stream JSON</a></dd>
            </div>
          </dl>
        </section>

        <section class="section-card">
          <div class="section-header">
            <div>
              <h2 class="section-title">Codex Transcript</h2>
              <p class="section-copy">Assistant messages and command output reconstructed from recent Codex events.</p>
            </div>
          </div>

          <%= if codex_blocks(@payload) == [] do %>
            <p class="empty-state">No Codex events captured for this issue yet.</p>
          <% else %>
            <div class="codex-stream">
              <article :for={block <- codex_blocks(@payload)} class={stream_block_class(block)}>
                <div class="codex-stream-body">
                  <%= if block.kind == :assistant do %>
                    <header class="codex-stream-header">
                      <span class="codex-stream-title">assistant</span>
                    </header>
                    <div class="codex-message"><%= block.text %></div>
                  <% else %>
                    <%= if block.kind == :tool do %>
                      <div class="codex-command-line">
                        <span class="codex-command-prompt">$</span>
                        <code><%= command_text(block) %></code>
                      </div>

                      <pre :if={has_output?(block)} class="codex-tool-output"><%= block.text %></pre>
                    <% else %>
                      <details class="codex-tool-details">
                        <summary><%= stream_summary(block) %></summary>
                        <pre class="codex-tool-output"><%= block.text %></pre>
                      </details>
                    <% end %>
                  <% end %>

                  <div class="codex-stream-debug">
                    <span class="codex-stream-meta"><%= stream_meta(block) %></span>
                    <details class="raw-event-details">
                      <summary>Raw JSON</summary>
                      <pre class="code-panel"><%= pretty_value(block.raw_events) %></pre>
                    </details>
                  </div>
                </div>
              </article>
            </div>
          <% end %>
        </section>
      <% end %>
    </section>
    """
  end

  defp assign_payload(socket) do
    case Presenter.issue_payload(socket.assigns.issue_identifier, orchestrator(), snapshot_timeout_ms()) do
      {:ok, payload} ->
        socket
        |> assign(:payload, payload)
        |> assign(:error, nil)

      {:error, :issue_not_found} ->
        socket
        |> assign(:payload, nil)
        |> assign(:error, "Issue not found in running, retrying, or blocked sessions.")
    end
  end

  defp codex_events(payload) do
    case payload.logs.codex_session_logs do
      events when is_list(events) and events != [] -> events
      _ -> payload.recent_events || []
    end
  end

  defp codex_blocks(payload), do: payload |> codex_events() |> SessionStream.blocks()

  defp stream_block_class(%{kind: kind}), do: "codex-stream-block codex-stream-block-#{kind}"

  defp command_text(%{command: command}) when is_binary(command), do: command

  defp command_text(%{title: "$ " <> command}), do: command
  defp command_text(%{title: title}), do: title

  defp has_output?(%{text: text}) when is_binary(text), do: String.trim(text) != ""
  defp has_output?(_block), do: false

  defp stream_meta(block) do
    parts =
      []
      |> append_meta(block.at)
      |> append_meta(event_count_label(block.event_count))

    Enum.join(parts, " · ")
  end

  defp append_meta(parts, nil), do: parts
  defp append_meta(parts, ""), do: parts
  defp append_meta(parts, value), do: parts ++ [value]

  defp event_count_label(count) when is_integer(count) and count > 1, do: "#{count} events"
  defp event_count_label(_count), do: nil

  defp stream_summary(%{kind: :tool} = block), do: "$ #{command_text(block)}"
  defp stream_summary(%{kind: :reasoning}), do: "reasoning"
  defp stream_summary(%{kind: :activity, title: title}), do: title
  defp stream_summary(_block), do: "details"

  defp session_id(%{running: %{session_id: session_id}}), do: session_id
  defp session_id(%{retry: %{session_id: session_id}}), do: session_id
  defp session_id(%{blocked: %{session_id: session_id}}), do: session_id
  defp session_id(_payload), do: nil

  defp format_tokens(%{running: %{tokens: tokens}}) do
    "#{format_int(tokens.input_tokens)} / #{format_int(tokens.output_tokens)} / #{format_int(tokens.total_tokens)}"
  end

  defp format_tokens(_payload), do: "n/a"

  defp format_int(value) when is_integer(value) do
    value
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/.{3}(?=.)/, "\\0,")
    |> String.reverse()
  end

  defp format_int(_value), do: "n/a"

  defp state_badge_class(state) do
    base = "state-badge"
    normalized = state |> to_string() |> String.downcase()

    cond do
      String.contains?(normalized, ["progress", "running", "active"]) -> "#{base} state-badge-active"
      String.contains?(normalized, ["blocked", "error", "failed"]) -> "#{base} state-badge-danger"
      String.contains?(normalized, ["todo", "queued", "pending", "retry"]) -> "#{base} state-badge-warning"
      true -> base
    end
  end

  defp pretty_value(nil), do: "n/a"
  defp pretty_value(value), do: inspect(value, pretty: true, limit: :infinity)

  defp orchestrator do
    Endpoint.config(:orchestrator) || SymphonyElixir.Orchestrator
  end

  defp snapshot_timeout_ms do
    Endpoint.config(:snapshot_timeout_ms) || 15_000
  end
end
