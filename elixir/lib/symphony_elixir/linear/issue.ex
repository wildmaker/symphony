defmodule SymphonyElixir.Linear.Issue do
  @moduledoc """
  Normalized Linear issue representation used by the orchestrator.
  """

  require Logger

  @model_label_prefix "model-"
  @reasoning_effort_label_prefix "reasoning-"
  @allowed_reasoning_efforts ~w(minimal low medium high xhigh)
  @base_branch_line ~r/^\s*(?:[-*]\s*)?(?:\*\*)?(?:base[\s_-]+branch|基准分支)(?:\*\*)?\s*[:=]\s*`?([^`\s#]+)`?/i

  defstruct [
    :id,
    :identifier,
    :title,
    :description,
    :priority,
    :state,
    :branch_name,
    :base_branch,
    :url,
    :assignee_id,
    blocked_by: [],
    labels: [],
    assigned_to_worker: true,
    created_at: nil,
    updated_at: nil
  ]

  @type t :: %__MODULE__{
          id: String.t() | nil,
          identifier: String.t() | nil,
          title: String.t() | nil,
          description: String.t() | nil,
          priority: integer() | nil,
          state: String.t() | nil,
          branch_name: String.t() | nil,
          base_branch: String.t() | nil,
          url: String.t() | nil,
          assignee_id: String.t() | nil,
          labels: [String.t()],
          assigned_to_worker: boolean(),
          created_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @spec label_names(t()) :: [String.t()]
  def label_names(%__MODULE__{labels: labels}) do
    labels
  end

  @spec model_override(t()) :: String.t() | nil
  def model_override(%__MODULE__{labels: labels}) do
    labels
    |> Enum.filter(&String.starts_with?(&1, @model_label_prefix))
    |> case do
      [] ->
        nil

      [label | rest] ->
        if rest != [], do: Logger.warning("Multiple model-* labels found on issue; using first: #{label}")
        String.replace_prefix(label, @model_label_prefix, "")
    end
  end

  @spec reasoning_effort_override(t()) :: String.t() | nil
  def reasoning_effort_override(%__MODULE__{labels: labels}) do
    labels
    |> Enum.map(&reasoning_effort_from_label/1)
    |> Enum.reject(&is_nil/1)
    |> case do
      [] ->
        nil

      [effort | rest] ->
        if rest != [], do: Logger.warning("Multiple reasoning-* labels found on issue; using first: #{effort}")
        effort
    end
  end

  @spec base_branch_from_description(String.t() | nil) :: String.t() | nil
  def base_branch_from_description(description) when is_binary(description) do
    description
    |> String.split(~r/\R/, trim: true)
    |> Enum.find_value(fn line ->
      case Regex.run(@base_branch_line, line, capture: :all_but_first) do
        [raw_branch] -> normalize_base_branch(raw_branch)
        _ -> nil
      end
    end)
  end

  def base_branch_from_description(_description), do: nil

  @spec normalize_base_branch(String.t() | nil) :: String.t() | nil
  def normalize_base_branch(branch) when is_binary(branch) do
    branch =
      branch
      |> String.trim()
      |> String.trim_leading("refs/heads/")
      |> String.trim_leading("origin/")
      |> strip_branch_wrappers()
      |> String.trim()

    if valid_base_branch?(branch), do: branch, else: nil
  end

  def normalize_base_branch(_branch), do: nil

  defp reasoning_effort_from_label(@reasoning_effort_label_prefix <> effort) do
    effort = String.downcase(effort)
    if effort in @allowed_reasoning_efforts, do: effort, else: nil
  end

  defp reasoning_effort_from_label(_label), do: nil

  defp valid_base_branch?(branch) when is_binary(branch) do
    byte_size(branch) in 1..255 and
      Regex.match?(~r/^[A-Za-z0-9][A-Za-z0-9._\/-]*[A-Za-z0-9]$/, branch) and
      not String.contains?(branch, ["..", "//", "@{"])
  end

  defp strip_branch_wrappers(branch) do
    branch
    |> String.trim("`")
    |> String.trim("'")
    |> String.trim("\"")
  end
end
