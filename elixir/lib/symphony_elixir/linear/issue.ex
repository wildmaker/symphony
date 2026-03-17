defmodule SymphonyElixir.Linear.Issue do
  @moduledoc """
  Normalized Linear issue representation used by the orchestrator.
  """

  require Logger

  @model_label_prefix "model-"

  defstruct [
    :id,
    :identifier,
    :title,
    :description,
    :priority,
    :state,
    :branch_name,
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
end
