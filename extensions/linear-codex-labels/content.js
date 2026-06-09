const DEFAULT_MODELS = [
  { label: "GPT-5.5", value: "gpt-5.5" },
  { label: "GPT-5.4", value: "gpt-5.4" },
  { label: "GPT-5.4 Mini", value: "gpt-5.4-mini" },
  { label: "GPT-5.3 Codex", value: "gpt-5.3-codex" },
  { label: "GPT-5.3 Codex Spark", value: "gpt-5.3-codex-spark" }
];

const REASONING_OPTIONS = [
  { label: "极低", value: "minimal" },
  { label: "低", value: "low" },
  { label: "中", value: "medium" },
  { label: "高", value: "high" },
  { label: "超高", value: "xhigh" }
];

const PRIORITIES = [
  { label: "No priority", value: "0" },
  { label: "Urgent", value: "1" },
  { label: "High", value: "2" },
  { label: "Medium", value: "3" },
  { label: "Low", value: "4" }
];

const SETTINGS_KEY = "symphonyCodexDefaults";
const METADATA_TTL_MS = 5 * 60 * 1000;

const state = {
  settings: {
    model: DEFAULT_MODELS[0].value,
    reasoning: "low"
  },
  metadata: null,
  metadataLoadedAt: 0,
  modal: null,
  form: null,
  busy: false
};

init();

async function init() {
  state.settings = await readSettings();
  installCreateInterceptors();
  observeSettingsChanges();
}

function installCreateInterceptors() {
  document.addEventListener("keydown", handleCreateShortcut, true);
  document.addEventListener("click", handleCreateClick, true);
}

function handleCreateShortcut(event) {
  if (
    event.defaultPrevented ||
    event.key?.toLowerCase() !== "c" ||
    event.metaKey ||
    event.ctrlKey ||
    event.altKey ||
    event.shiftKey ||
    state.modal ||
    isEditingTarget(event.target)
  ) {
    return;
  }

  event.preventDefault();
  event.stopImmediatePropagation();
  openCreator();
}

function handleCreateClick(event) {
  if (event.defaultPrevented || state.modal || isEditingTarget(event.target)) {
    return;
  }

  const target = event.target instanceof Element ? event.target : null;
  const button = target?.closest('button, a, [role="button"]');
  if (!button || !looksLikeCreateIssueButton(button)) {
    return;
  }

  event.preventDefault();
  event.stopImmediatePropagation();
  openCreator();
}

function isEditingTarget(target) {
  if (!(target instanceof Element)) {
    return false;
  }

  return Boolean(target.closest("input, textarea, select, [contenteditable='true'], [role='textbox'], .symphony-creator"));
}

function looksLikeCreateIssueButton(element) {
  if (element.closest(".symphony-creator")) {
    return false;
  }

  const text = normalizeText(
    [
      element.textContent,
      element.getAttribute("aria-label"),
      element.getAttribute("title"),
      element.getAttribute("data-testid")
    ]
      .filter(Boolean)
      .join(" ")
  );

  if (/create (new )?issue|new issue|issue create|createIssue/i.test(text)) {
    return true;
  }

  const rect = element.getBoundingClientRect();
  const visibleText = normalizeText(element.textContent || "");
  const hasPlusIcon =
    visibleText === "+" ||
    element.querySelector('svg path[d*="M12 5"], svg path[d*="M5 12"], svg line, svg [data-icon*="plus" i]');

  return Boolean(hasPlusIcon && rect.left < 230 && rect.top > 55 && rect.top < 140 && rect.width <= 48 && rect.height <= 48);
}

async function openCreator() {
  if (state.modal) {
    return;
  }

  renderShell();
  setStatus("正在加载 Linear 数据...");

  try {
    state.settings = await readSettings();
    state.metadata = await loadMetadata();
    renderForm();
  } catch (error) {
    renderError(error.message || String(error));
  }
}

function renderShell() {
  const root = document.createElement("div");
  root.className = "symphony-creator";
  root.innerHTML = `
    <div class="symphony-creator-backdrop" data-close="true"></div>
    <section class="symphony-creator-dialog" role="dialog" aria-modal="true" aria-label="Create Linear issue">
      <header class="symphony-creator-header">
        <div>
          <p class="symphony-creator-kicker">Linear issue</p>
          <h2>Create issue</h2>
        </div>
        <button type="button" class="symphony-icon-button" data-close="true" aria-label="Close">×</button>
      </header>
      <div class="symphony-creator-body" data-body>
        <div class="symphony-loading">正在加载...</div>
      </div>
    </section>
  `;

  root.addEventListener("click", (event) => {
    if (event.target instanceof Element && event.target.dataset.close === "true") {
      closeCreator();
    }
  });

  document.addEventListener("keydown", handleModalKeydown, true);
  document.body.append(root);
  state.modal = root;
}

function handleModalKeydown(event) {
  if (!state.modal) {
    return;
  }

  if (event.key === "Escape") {
    event.preventDefault();
    if (isLabelDropdownOpen()) {
      closeLabelDropdown();
      return;
    }

    closeCreator();
  }
}

function renderForm() {
  const context = inferContext(state.metadata);
  const modelLabel = `model-${state.settings.model}`;
  const reasoningLabel = `reasoning-${state.settings.reasoning}`;
  const labels = selectInitialLabels(context.team, [modelLabel, reasoningLabel]);
  const states = statesForTeam(context.team);
  const projects = projectsForTeam(context.team);
  const users = activeUsers();

  const body = state.modal.querySelector("[data-body]");
  body.innerHTML = `
    <form class="symphony-form" data-form>
      <label class="symphony-title-field">
        <span>Title</span>
        <input name="title" autocomplete="off" placeholder="Issue title" required>
      </label>

      <label class="symphony-description-field">
        <span>Description</span>
        <textarea name="description" placeholder="Description in Markdown"></textarea>
      </label>

      <div class="symphony-grid">
        ${renderSelect("teamId", "Team", teams(), context.team?.id || "", true)}
        ${renderSelect("stateId", "Status", states, defaultStateId(states), false)}
        ${renderSelect("priority", "Priority", PRIORITIES, "0", false)}
        ${renderSelect("assigneeId", "Assignee", users, "", false)}
        ${renderSelect("projectId", "Project", projects, context.project?.id || "", false)}
        ${renderSelect("model", "Model", DEFAULT_MODELS, state.settings.model, true)}
        ${renderSelect("reasoning", "Reasoning", REASONING_OPTIONS, state.settings.reasoning, true)}
      </div>

      <section class="symphony-label-dropdown" data-label-dropdown data-menu-open="false">
        <button type="button" role="combobox" class="symphony-control-pill sc2sx-Button-a8f3e7c2" data-label-toggle aria-expanded="false" aria-label="Change labels">
          <span class="symphony-label-dots" data-label-dots></span>
          <span data-label-summary>Labels</span>
        </button>
        <div class="symphony-label-menu" data-label-menu hidden>
          <input class="symphony-label-search" data-label-search placeholder="Change or add labels..." autocomplete="off">
          <div class="symphony-label-list" data-label-list></div>
        </div>
      </section>

      <footer class="symphony-actions">
        <p class="symphony-status" data-status></p>
        <label class="symphony-create-more">
          <input name="createMore" type="checkbox">
          <span>Create more</span>
        </label>
        <button type="button" class="symphony-secondary" data-close="true">Cancel</button>
        <button type="submit" class="symphony-primary">Create issue</button>
      </footer>
    </form>
  `;

  state.form = body.querySelector("[data-form]");
  state.form.addEventListener("submit", handleSubmit);
  state.form.teamId.addEventListener("change", syncTeamDependentFields);
  state.form.model.addEventListener("change", syncModelLabels);
  state.form.reasoning.addEventListener("change", syncModelLabels);
  state.form.querySelector("[data-label-toggle]").addEventListener("click", toggleLabelDropdown);
  state.form.querySelector("[data-label-search]").addEventListener("input", filterLabelOptions);
  state.form.querySelector("[data-label-list]").addEventListener("change", updateLabelSummary);
  state.form.addEventListener("click", closeLabelDropdownOnOutsideClick);

  renderLabelList(labels);
  state.form.title.focus();
  setStatus("");
}

function renderSelect(name, label, options, selectedValue, required) {
  const requiredAttr = required ? "required" : "";
  const empty = required ? "" : '<option value="">None</option>';
  const optionHtml = options
    .map((option) => {
      const value = option.value ?? option.id;
      const text = escapeHtml(option.label ?? option.name ?? option.displayName ?? option.key ?? value);
      const selected = value === selectedValue ? "selected" : "";
      return `<option value="${escapeAttribute(value)}" ${selected}>${text}</option>`;
    })
    .join("");

  return `
    <label class="symphony-field">
      <span>${escapeHtml(label)}</span>
      <select name="${escapeAttribute(name)}" ${requiredAttr}>${empty}${optionHtml}</select>
    </label>
  `;
}

function renderLabelList(selectedLabels) {
  const team = teamById(state.form.teamId.value);
  const labels = labelsForTeam(team);
  const selectedIds = new Set(selectedLabels.map((label) => label.id));
  const fixedNames = new Set(currentCodexLabelNames());
  const list = state.form.querySelector("[data-label-list]");

  list.innerHTML = labels
    .map((label) => {
      const checked = selectedIds.has(label.id) ? "checked" : "";
      const disabled = fixedNames.has(label.name) ? "disabled" : "";
      const fixed = fixedNames.has(label.name) ? "data-fixed=\"true\"" : "";
      return `
        <label class="symphony-label-chip" data-label-row data-label-name="${escapeAttribute(label.name)}" ${fixed}>
          <input type="checkbox" name="labelIds" value="${escapeAttribute(label.id)}" data-label-name="${escapeAttribute(label.name)}" ${checked} ${disabled}>
          <span class="symphony-label-dot" style="--label-color: ${escapeAttribute(label.color || "#6b7280")}"></span>
          <span>${escapeHtml(label.name)}</span>
        </label>
      `;
    })
    .join("");

  updateLabelSummary();
  filterLabelOptions();
}

async function syncTeamDependentFields() {
  const team = teamById(state.form.teamId.value);
  await ensureTeamDetails(team);
  setSelectOptions(state.form.stateId, statesForTeam(team), defaultStateId(statesForTeam(team)), true);
  setSelectOptions(state.form.projectId, projectsForTeam(team), "", false);
  renderLabelList(selectInitialLabels(team, currentCodexLabelNames()));
}

function setSelectOptions(select, options, selectedValue, required) {
  const empty = required ? "" : '<option value="">None</option>';
  select.innerHTML =
    empty +
    options
      .map((option) => {
        const value = option.value ?? option.id;
        const text = escapeHtml(option.label ?? option.name ?? option.displayName ?? option.key ?? value);
        const selected = value === selectedValue ? "selected" : "";
        return `<option value="${escapeAttribute(value)}" ${selected}>${text}</option>`;
      })
      .join("");
}

function syncModelLabels() {
  const team = teamById(state.form.teamId.value);
  const selectedNonCodexLabels = selectedLabelIds()
    .map((id) => labelsForTeam(team).find((label) => label.id === id))
    .filter((label) => label && !isCodexLabel(label.name));
  renderLabelList([...selectedNonCodexLabels, ...selectInitialLabels(team, currentCodexLabelNames())]);
}

function toggleLabelDropdown() {
  const menu = state.form.querySelector("[data-label-menu]");
  const toggle = state.form.querySelector("[data-label-toggle]");
  const isOpen = !menu.hidden;

  menu.hidden = isOpen;
  toggle.setAttribute("aria-expanded", isOpen ? "false" : "true");
  state.form.querySelector("[data-label-dropdown]").dataset.menuOpen = isOpen ? "false" : "true";

  if (!isOpen) {
    const search = state.form.querySelector("[data-label-search]");
    search.value = "";
    filterLabelOptions();
    search.focus();
  }
}

function isLabelDropdownOpen() {
  const menu = state.form?.querySelector("[data-label-menu]");
  return Boolean(menu && !menu.hidden);
}

function closeLabelDropdown() {
  const menu = state.form?.querySelector("[data-label-menu]");
  const toggle = state.form?.querySelector("[data-label-toggle]");
  if (!menu || menu.hidden) {
    return;
  }

  menu.hidden = true;
  toggle?.setAttribute("aria-expanded", "false");
  state.form?.querySelector("[data-label-dropdown]")?.setAttribute("data-menu-open", "false");
}

function closeLabelDropdownOnOutsideClick(event) {
  if (event.target instanceof Element && event.target.closest("[data-label-dropdown]")) {
    return;
  }

  closeLabelDropdown();
}

function filterLabelOptions() {
  const query = normalizeComparable(state.form.querySelector("[data-label-search]").value);
  state.form.querySelectorAll("[data-label-row]").forEach((chip) => {
    const label = normalizeComparable(chip.dataset.labelName || "");
    chip.hidden = Boolean(query && !label.includes(query));
  });
}

function updateLabelSummary() {
  const team = teamById(state.form.teamId.value);
  const selected = selectedLabelIds()
    .map((id) => labelsForTeam(team).find((label) => label.id === id))
    .filter(Boolean);
  const summary = state.form.querySelector("[data-label-summary]");
  const dots = state.form.querySelector("[data-label-dots]");
  const count = selected.length;

  summary.textContent = count === 0 ? "Labels" : count === 1 ? "1 label" : `${count} labels`;
  dots.innerHTML = selected
    .slice(0, 4)
    .map((label) => `<span class="symphony-label-dot" style="--label-color: ${escapeAttribute(label.color || "#6b7280")}"></span>`)
    .join("");
}

function selectedLabelIds() {
  return [...state.form.querySelectorAll('input[name="labelIds"]:checked')]
    .map((input) => input.value)
    .filter(Boolean);
}

async function handleSubmit(event) {
  event.preventDefault();

  if (state.busy) {
    return;
  }

  const title = state.form.title.value.trim();
  if (!title) {
    setStatus("请填写标题", true);
    state.form.title.focus();
    return;
  }

  const input = issueInputFromForm(title);
  const createMore = state.form.createMore.checked;

  state.busy = true;
  setFormBusy(true);
  setStatus("正在创建 issue...");

  try {
    const result = await createIssue(input);
    setStatus(`已创建 ${result.issue.identifier || result.issue.title}`);

    if (createMore) {
      resetForCreateMore();
    } else {
      window.setTimeout(closeCreator, 450);
    }
  } catch (error) {
    setStatus(error.message || String(error), true);
  } finally {
    state.busy = false;
    setFormBusy(false);
  }
}

function issueInputFromForm(title) {
  const formData = new FormData(state.form);
  const labelIds = [...state.form.querySelectorAll('input[name="labelIds"]:checked')]
    .map((input) => input.value)
    .filter(Boolean);

  const input = {
    title,
    teamId: formData.get("teamId"),
    labelIds
  };

  const optionalStrings = ["description", "stateId", "assigneeId", "projectId"];
  for (const key of optionalStrings) {
    const value = String(formData.get(key) || "").trim();
    if (value) {
      input[key] = value;
    }
  }

  const priority = Number(formData.get("priority") || 0);
  if (Number.isInteger(priority) && priority >= 0) {
    input.priority = priority;
  }

  return input;
}

function resetForCreateMore() {
  state.form.title.value = "";
  state.form.description.value = "";
  state.form.title.focus();
}

function setFormBusy(isBusy) {
  state.form.querySelectorAll("input, textarea, select, button").forEach((element) => {
    if (element.name !== "createMore") {
      if (element.closest("[data-fixed='true']")) {
        element.disabled = true;
        return;
      }

      element.disabled = isBusy;
    }
  });
}

function closeCreator() {
  document.removeEventListener("keydown", handleModalKeydown, true);
  state.modal?.remove();
  state.modal = null;
  state.form = null;
  state.busy = false;
}

function setStatus(message, isError = false) {
  const status = state.modal?.querySelector("[data-status]");
  if (status) {
    status.textContent = message;
    status.dataset.error = isError ? "true" : "false";
  }
}

function renderError(message) {
  const body = state.modal.querySelector("[data-body]");
  body.innerHTML = `
    <div class="symphony-error-panel">
      <h3>无法加载 Linear 数据</h3>
      <p>${escapeHtml(message)}</p>
      <p>请在扩展弹窗中配置 Linear API Key，然后重试。</p>
      <button type="button" class="symphony-secondary" data-close="true">Close</button>
    </div>
  `;
}

async function loadMetadata() {
  if (state.metadata && Date.now() - state.metadataLoadedAt < METADATA_TTL_MS) {
    return state.metadata;
  }

  const teamKey = findTeamKey();
  const metadata = emptyMetadata();
  const baseMetadata = await sendMessage({
    type: "linearGraphql",
    query: `
      query SymphonyCreatorBaseMetadata {
        teams(first: 100) {
          nodes { id key name }
        }
        users(first: 100) {
          nodes { id name displayName active avatarUrl }
        }
      }
    `
  });

  metadata.teams = baseMetadata.teams || metadata.teams;
  metadata.users = baseMetadata.users || metadata.users;

  const initialTeam =
    teams(metadata).find((team) => team.key === teamKey) ||
    teams(metadata)[0] ||
    null;

  if (initialTeam) {
    await loadTeamDetailsIntoMetadata(metadata, initialTeam.key);
  }

  state.metadataLoadedAt = Date.now();
  state.metadata = metadata;
  return metadata;
}

function emptyMetadata() {
  return {
    teams: { nodes: [] },
    users: { nodes: [] },
    workflowStates: { nodes: [] },
    projects: { nodes: [] },
    issueLabels: { nodes: [] },
    loadedTeamKeys: []
  };
}

async function ensureTeamDetails(team) {
  if (!team || state.metadata?.loadedTeamKeys?.includes(team.key)) {
    return;
  }

  setStatus("正在加载团队数据...");
  await loadTeamDetailsIntoMetadata(state.metadata, team.key);
  setStatus("");
}

async function loadTeamDetailsIntoMetadata(metadata, teamKey) {
  const data = await sendMessage({
    type: "linearGraphql",
    query: `
      query SymphonyCreatorTeamMetadata($teamKey: String!) {
        team(id: $teamKey) {
          id
          key
          name
          states(first: 50) {
            nodes { id name type color }
          }
          labels(first: 100) {
            nodes { id name color }
          }
          projects(first: 100) {
            nodes { id name }
          }
        }
      }
    `,
    variables: { teamKey }
  });

  if (!data.team) {
    throw new Error(`Linear team ${teamKey} not found.`);
  }

  mergeTeamDetails(metadata, data.team);
}

function mergeTeamDetails(metadata, team) {
  const teamRef = { id: team.id, key: team.key };
  metadata.workflowStates.nodes = [
    ...metadata.workflowStates.nodes.filter((item) => item.team?.id !== team.id),
    ...(team.states?.nodes || []).map((item) => ({ ...item, team: teamRef }))
  ];
  metadata.projects.nodes = [
    ...metadata.projects.nodes.filter((item) => !(item.teams?.nodes || []).some((projectTeam) => projectTeam.id === team.id)),
    ...(team.projects?.nodes || []).map((item) => ({ ...item, teams: { nodes: [teamRef] } }))
  ];
  metadata.issueLabels.nodes = [
    ...metadata.issueLabels.nodes.filter((item) => item.team?.id !== team.id),
    ...(team.labels?.nodes || []).map((item) => ({ ...item, team: teamRef }))
  ];

  if (!metadata.loadedTeamKeys.includes(team.key)) {
    metadata.loadedTeamKeys.push(team.key);
  }
}

async function createIssue(input) {
  return sendMessage({
    type: "linearGraphql",
    query: `
      mutation SymphonyIssueCreate($input: IssueCreateInput!) {
        issueCreate(input: $input) {
          success
          issue { id identifier title url }
        }
      }
    `,
    variables: { input }
  }).then((result) => {
    if (!result.issueCreate?.success) {
      throw new Error("Linear did not create the issue.");
    }

    return result.issueCreate;
  });
}

function sendMessage(message) {
  return new Promise((resolve, reject) => {
    chrome.runtime.sendMessage(message, (response) => {
      if (chrome.runtime.lastError) {
        reject(new Error(chrome.runtime.lastError.message));
        return;
      }

      if (!response?.ok) {
        reject(new Error(response?.error || "Linear request failed."));
        return;
      }

      resolve(response.data);
    });
  });
}

function inferContext(metadata) {
  const teamKey = findTeamKey();
  const projectName = findProjectName();
  const team = teams(metadata).find((item) => item.key === teamKey) || teams(metadata)[0] || null;
  const project =
    projectsForTeam(team, metadata).find((item) => normalizeComparable(item.name) === normalizeComparable(projectName)) ||
    projectsForTeam(team, metadata)[0] ||
    null;

  return { team, project };
}

function findTeamKey() {
  const teamPathMatch = window.location.pathname.match(/\/team\/([^/]+)/);
  if (teamPathMatch) {
    return teamPathMatch[1].toUpperCase();
  }

  const issueIds = document.body.textContent?.match(/\b[A-Z][A-Z0-9]{1,9}-\d+\b/g) || [];
  const counts = new Map();
  for (const issueId of issueIds) {
    const key = issueId.split("-")[0];
    counts.set(key, (counts.get(key) || 0) + 1);
  }

  return [...counts.entries()].sort((left, right) => right[1] - left[1])[0]?.[0] || "";
}

function findProjectName() {
  const titleName = normalizeText((document.title || "").split("›")[0] || "");
  if (titleName && titleName !== "Linear") {
    return titleName;
  }

  return "";
}

function teams(metadata = state.metadata) {
  return metadata?.teams?.nodes || [];
}

function teamById(teamId) {
  return teams().find((team) => team.id === teamId) || null;
}

function statesForTeam(team, metadata = state.metadata) {
  return (metadata?.workflowStates?.nodes || []).filter((stateItem) => stateItem.team?.id === team?.id);
}

function defaultStateId(states) {
  return states.find((stateItem) => /backlog/i.test(stateItem.type || stateItem.name))?.id || states[0]?.id || "";
}

function activeUsers(metadata = state.metadata) {
  return (metadata?.users?.nodes || [])
    .filter((user) => user.active !== false)
    .map((user) => ({ id: user.id, name: user.displayName || user.name }));
}

function projectsForTeam(team, metadata = state.metadata) {
  return (metadata?.projects?.nodes || []).filter((project) =>
    (project.teams?.nodes || []).some((projectTeam) => projectTeam.id === team?.id)
  );
}

function labelsForTeam(team, metadata = state.metadata) {
  return (metadata?.issueLabels?.nodes || []).filter((label) => !label.team || label.team.id === team?.id);
}

function selectInitialLabels(team, labelNames) {
  const wanted = new Set(labelNames);
  const selected = [];

  for (const label of labelsForTeam(team)) {
    if (wanted.has(label.name)) {
      selected.push(label);
    }
  }

  return selected;
}

function currentCodexLabelNames() {
  return [`model-${state.form.model.value}`, `reasoning-${state.form.reasoning.value}`];
}

function isCodexLabel(labelName) {
  return /^model-|^reasoning-/.test(labelName || "");
}

function readSettings() {
  return new Promise((resolve) => {
    chrome.storage.local.get(SETTINGS_KEY, (result) => {
      const settings = result?.[SETTINGS_KEY] || {};
      resolve({
        model: DEFAULT_MODELS.some((item) => item.value === settings.model) ? settings.model : DEFAULT_MODELS[0].value,
        reasoning: REASONING_OPTIONS.some((item) => item.value === settings.reasoning) ? settings.reasoning : "low"
      });
    });
  });
}

function observeSettingsChanges() {
  chrome.storage.onChanged.addListener((changes, areaName) => {
    if (areaName !== "local" || !changes[SETTINGS_KEY]) {
      return;
    }

    state.settings = {
      model: DEFAULT_MODELS.some((item) => item.value === changes[SETTINGS_KEY].newValue?.model)
        ? changes[SETTINGS_KEY].newValue.model
        : DEFAULT_MODELS[0].value,
      reasoning: REASONING_OPTIONS.some((item) => item.value === changes[SETTINGS_KEY].newValue?.reasoning)
        ? changes[SETTINGS_KEY].newValue.reasoning
        : "low"
    };
  });
}

function normalizeText(text) {
  return text.replace(/\s+/g, " ").trim();
}

function normalizeComparable(text) {
  return normalizeText(text || "").toLowerCase();
}

function escapeHtml(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function escapeAttribute(value) {
  return escapeHtml(value).replace(/'/g, "&#39;");
}
