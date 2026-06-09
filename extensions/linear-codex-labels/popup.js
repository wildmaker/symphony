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

const SETTINGS_KEY = "symphonyCodexDefaults";
const DEFAULT_SETTINGS = {
  apiKey: "",
  model: DEFAULT_MODELS[0].value,
  reasoning: "low"
};

const settingsForm = document.querySelector("#settingsForm");
const apiKeyInput = document.querySelector("#apiKey");
const modelSelect = document.querySelector("#model");
const reasoningSelect = document.querySelector("#reasoning");
const statusElement = document.querySelector("#status");
const saveButton = document.querySelector("#saveButton");

init();

async function init() {
  fillOptions(modelSelect, DEFAULT_MODELS);
  fillOptions(reasoningSelect, REASONING_OPTIONS);

  const settings = normalizeSettings(await readSettings());
  apiKeyInput.value = settings.apiKey;
  modelSelect.value = settings.model;
  reasoningSelect.value = settings.reasoning;

  apiKeyInput.addEventListener("paste", handleApiKeyPaste);
  apiKeyInput.addEventListener("keydown", handleApiKeyShortcut);
  settingsForm.addEventListener("submit", handleSave);
}

function fillOptions(select, options) {
  for (const option of options) {
    const element = document.createElement("option");
    element.value = option.value;
    element.textContent = option.label;
    select.append(element);
  }
}

function readSettings() {
  return new Promise((resolve) => {
    chrome.storage.local.get(SETTINGS_KEY, (result) => {
      resolve(result?.[SETTINGS_KEY] || DEFAULT_SETTINGS);
    });
  });
}

async function handleSave(event) {
  event.preventDefault();

  const settings = normalizeSettings({
    apiKey: apiKeyInput.value,
    model: modelSelect.value,
    reasoning: reasoningSelect.value
  });

  setBusy(true);

  try {
    if (settings.apiKey) {
      setStatus("正在测试 Linear API Key...");
      await testApiKey(settings.apiKey);
    }

    await saveSettings(settings);
    setStatus(settings.apiKey ? "测试通过，已保存" : "已清空 API Key 并保存");
  } catch (error) {
    setStatus(error.message || String(error), true);
  } finally {
    setBusy(false);
  }
}

function saveSettings(settings) {
  return new Promise((resolve) => {
    chrome.storage.local.set({ [SETTINGS_KEY]: settings }, resolve);
  });
}

function testApiKey(apiKey) {
  return new Promise((resolve, reject) => {
    chrome.runtime.sendMessage({ type: "linearTestApiKey", apiKey }, (response) => {
      if (chrome.runtime.lastError) {
        reject(new Error(chrome.runtime.lastError.message));
        return;
      }

      if (!response?.ok) {
        reject(new Error(response?.error || "Linear API Key 测试失败"));
        return;
      }

      resolve(response.data);
    });
  });
}

function handleApiKeyPaste(event) {
  const text = event.clipboardData?.getData("text");
  if (!text) {
    return;
  }

  event.preventDefault();
  setApiKeyValue(text);
}

async function handleApiKeyShortcut(event) {
  if (!(event.metaKey || event.ctrlKey)) {
    return;
  }

  const key = event.key.toLowerCase();
  if (key === "a") {
    event.preventDefault();
    apiKeyInput.focus();
    apiKeyInput.select();
    apiKeyInput.setSelectionRange(0, apiKeyInput.value.length);
    return;
  }

  if (key !== "v") {
    return;
  }

  const beforeValue = apiKeyInput.value;
  const selectionStart = apiKeyInput.selectionStart ?? beforeValue.length;
  const selectionEnd = apiKeyInput.selectionEnd ?? beforeValue.length;

  window.setTimeout(async () => {
    if (apiKeyInput.value !== beforeValue) {
      setStatus("已填入，点击保存并测试");
      return;
    }

    try {
      const text = await navigator.clipboard.readText();
      if (text) {
        setApiKeyValue(`${beforeValue.slice(0, selectionStart)}${text.trim()}${beforeValue.slice(selectionEnd)}`);
      }
    } catch (_error) {
      statusElement.textContent = "请用右键粘贴或重新授权剪贴板";
    }
  }, 0);
}

function setApiKeyValue(value) {
  apiKeyInput.value = value.trim();
  setStatus("已填入，点击保存并测试");
}

function setBusy(isBusy) {
  saveButton.disabled = isBusy;
  apiKeyInput.disabled = isBusy;
  modelSelect.disabled = isBusy;
  reasoningSelect.disabled = isBusy;
}

function setStatus(message, isError = false) {
  statusElement.textContent = message;
  statusElement.dataset.error = isError ? "true" : "false";
}

function normalizeSettings(settings) {
  return {
    apiKey: normalizeApiKey(settings?.apiKey),
    model: DEFAULT_MODELS.some((item) => item.value === settings?.model) ? settings.model : DEFAULT_SETTINGS.model,
    reasoning: REASONING_OPTIONS.some((item) => item.value === settings?.reasoning)
      ? settings.reasoning
      : DEFAULT_SETTINGS.reasoning
  };
}

function normalizeApiKey(apiKey) {
  return typeof apiKey === "string" ? apiKey.trim().replace(/^Bearer\s+/i, "") : DEFAULT_SETTINGS.apiKey;
}
