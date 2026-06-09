const SETTINGS_KEY = "symphonyCodexDefaults";
const LINEAR_GRAPHQL_URL = "https://api.linear.app/graphql";

chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
  if (message?.type !== "linearGraphql" && message?.type !== "linearTestApiKey") {
    return false;
  }

  handleMessage(message)
    .then((data) => sendResponse({ ok: true, data }))
    .catch((error) => sendResponse({ ok: false, error: error.message || String(error) }));

  return true;
});

function handleMessage(message) {
  if (message.type === "linearTestApiKey") {
    return testLinearApiKey(message.apiKey);
  }

  return handleLinearGraphql(message);
}

async function handleLinearGraphql(message) {
  const settings = await readSettings();
  return requestLinearGraphql(settings.apiKey, message.query, message.variables || {});
}

function testLinearApiKey(apiKey) {
  return requestLinearGraphql(apiKey, `
    query SymphonyApiKeyTest {
      viewer { id name }
    }
  `);
}

async function requestLinearGraphql(apiKey, query, variables = {}) {
  const key = normalizeApiKey(apiKey);
  if (!key) {
    throw new Error("Linear API Key is not configured.");
  }

  const response = await fetch(LINEAR_GRAPHQL_URL, {
    method: "POST",
    headers: {
      Authorization: key,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ query, variables })
  });

  const payload = await response.json().catch(() => null);

  if (!response.ok) {
    throw new Error(payload?.errors?.[0]?.message || `Linear API request failed (${response.status}).`);
  }

  if (payload?.errors?.length) {
    throw new Error(payload.errors.map((error) => error.message).join("; "));
  }

  return payload?.data || {};
}

function normalizeApiKey(apiKey) {
  return String(apiKey || "").trim().replace(/^Bearer\s+/i, "");
}

function readSettings() {
  return new Promise((resolve) => {
    chrome.storage.local.get(SETTINGS_KEY, (result) => {
      resolve(result?.[SETTINGS_KEY] || {});
    });
  });
}
