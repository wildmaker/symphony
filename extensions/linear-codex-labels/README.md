# Symphony Linear Codex Labels

Chrome extension for Linear issue creation. It replaces Linear's create issue entry with a custom issue creator that can create issues through Linear's GraphQL API while always applying Codex-style model and reasoning labels.

This extension uses the Linear API:

- A Linear API key is required.
- The API key is stored in browser extension local storage.
- Missing labels are not created automatically.
- The required labels must already exist in Linear.

## Labels

The extension applies two labels:

- `model-<model>`
- `reasoning-<effort>`

Default model options:

- `model-gpt-5.5`
- `model-gpt-5.4`
- `model-gpt-5.4-mini`
- `model-gpt-5.3-codex`
- `model-gpt-5.3-codex-spark`

Reasoning options:

- `reasoning-minimal`
- `reasoning-low`
- `reasoning-medium`
- `reasoning-high`
- `reasoning-xhigh`

## Install Locally

1. Open `chrome://extensions`.
2. Enable Developer mode.
3. Click **Load unpacked**.
4. Select this directory: `extensions/linear-codex-labels`.
5. Refresh Linear.

## Configure Defaults

Click the extension icon and configure:

- Linear API Key
- Default model
- Default reasoning effort

Click **保存并测试**. If an API key is present, the extension runs a small Linear GraphQL request before saving. The API key and defaults are stored in the browser and used when the extension intercepts Linear's create issue shortcut or button.

## How It Works

Linear does not support the needed custom fields, so this extension uses labels as the storage layer.

When you click Linear's create issue button or press `C`, the extension opens its own issue creator. The custom UI supports:

- Title
- Description
- Team
- Status
- Priority
- Assignee
- Project
- Labels
- Model
- Reasoning effort
- Create more

The model and reasoning controls are mutually exclusive. When creating an issue, the extension sends exactly one `model-*` label and one `reasoning-*` label through `issueCreate`.

If a label is missing, the extension shows an error and does not create it.

Symphony then reads those labels:

- `model-*` rewrites the Codex `--model` argument.
- `reasoning-*` adds or rewrites `--config model_reasoning_effort=<effort>`.
